define([
    'jquery',
    'underscore',
    'widget/result-summary',
    'widget/result-summaries',
    'widget/plan-status-history'
], function(
    $,
    _,
    ResultSummary,
    ResultSummaries,
    PlanStatusHistory
) {

    'use strict';

    module('Bamboo.PlanStatusHistory', {
        setup: function() {
            // fake all XHR
            this.server = sinon.useFakeXMLHttpRequest();
            this.requests = [];

            // catch all requests
            this.server.onCreate = _.bind(function(xhr) {
                this.requests.push(xhr);
            }, this);

            this.ResultSummaries = ResultSummaries.extend({
                fetch: function() {
                    return [];
                }
            });

            this.Navigator = PlanStatusHistory.extend({
                scheduleNextUpdate: function() {}
            });

            var $fixture = $('#qunit-fixture')
                    .append('<span class="spinner previous"></span>')
                    .append('<span class="spinner next"></span>');
            this.navigator = new this.Navigator({
                el: $fixture
            });

            this.navigator.render = sinon.spy(this.navigator, 'render');

            sinon.spy(this.Navigator.prototype, 'clickPreviousButton');
            sinon.spy(this.Navigator.prototype, 'clickNextButton');
            sinon.spy(this.Navigator.prototype, 'update');

            this.testHelper = {
                generateBuilds: function (fromBuildNumber, toBuildNumber) {
                    var builds = [];
                    for (var i = fromBuildNumber; i <= toBuildNumber; i++) {
                        builds.push({buildNumber: i});
                    }
                    return builds;
                }
            };
        },
        teardown: function() {
            this.server.restore();
            this.navigator.render.restore();
            this.Navigator.prototype.clickPreviousButton.restore();
            this.Navigator.prototype.clickNextButton.restore();
            this.Navigator.prototype.update.restore();
        }
    });

    test('is called on init', function() {
        var Navigator = PlanStatusHistory.extend({
            scheduleNextUpdate: sinon.spy()
        });

        var nav = new Navigator();

        ok(
            nav.scheduleNextUpdate.calledOnce,
            'should be called on init'
        );
    });

    test('is called when #updateReturnUrls is called', function() {
        this.navigator.updateReturnUrls(null, '');

        ok(
            this.navigator.render.calledOnce,
            'should render when updateReturnUrls is called'
        );
    });

    test('PlanStatusHistory getBuildsToRender', function() {
        var models = [new ResultSummary({buildNumber: 123}), new ResultSummary({buildNumber: 125})];
        var nav = new this.Navigator({
            bootstrap: models
        });

        var buildsToRender = nav.getBuildsToRender();
        propEqual(buildsToRender, [{buildNumber: 123}, {buildNumber: 125}]);

        nav.collection.push(new ResultSummary({buildNumber: 127, active: true}));
        nav.maxVisibleBuildNumber = 125;
        buildsToRender = nav.getBuildsToRender();
        propEqual(buildsToRender, [{buildNumber: 123}, {buildNumber: 125}]);

        nav.minVisibleBuildNumber = 127;
        nav.maxVisibleBuildNumber = 127;
        buildsToRender = nav.getBuildsToRender();
        propEqual(buildsToRender, [{buildNumber: 127, active: true}]);
    });

    test('PlanStatusHistory needsFetchOnScroll', function() {
        var models = [];
        var nav = new this.Navigator({
            bootstrap: models
        });

        equal(true, nav.needsFetchOnScroll("before"));
        equal(true, nav.needsFetchOnScroll("after"));

        models.push(new ResultSummary({buildNumber: 123}));
        nav = new this.Navigator({
            bootstrap: models
        });

        equal(true, nav.needsFetchOnScroll("before"));
        equal(true, nav.needsFetchOnScroll("after"));

        models.push(new ResultSummary({buildNumber: 125}));
        models.push(new ResultSummary({buildNumber: 127}));
        models.push(new ResultSummary({buildNumber: 129}));
        nav = new this.Navigator({
            bootstrap: models
        });

        equal(true, nav.needsFetchOnScroll("before"));

        nav.minVisibleBuildNumber = 125;
        equal(true, nav.needsFetchOnScroll("before"));

        nav.minVisibleBuildNumber = 127;
        equal(false, nav.needsFetchOnScroll("before"));

        nav.minVisibleBuildNumber = 129;
        equal(false, nav.needsFetchOnScroll("before"));

        nav = new this.Navigator({
            bootstrap: models
        });

        equal(true, nav.needsFetchOnScroll("after"));

        nav.maxVisibleBuildNumber = 127;
        equal(true, nav.needsFetchOnScroll("after"));

        nav.maxVisibleBuildNumber = 125;
        equal(false, nav.needsFetchOnScroll("after"));

        nav.maxVisibleBuildNumber = 123;
        equal(false, nav.needsFetchOnScroll("after"));
    });

    test('PlanStatusHistory clickPreviousButton: current build is the first build', function() {
        var models = this.testHelper.generateBuilds(1, 10);

        var nav = new this.Navigator({
            bootstrap: models,
            buildNumber: 1,
            firstBuildNumber: 1,
            lastBuildNumber: 30
        });

        var lastMinVisibleBuildNumber = nav.minVisibleBuildNumber;
        var lastMaxVisibleBuildNumber = nav.maxVisibleBuildNumber;

        nav.$el.find("a.previous").click();

        ok(
            !nav.clickPreviousButton.called,
            'clickPreviousButton should NOT be called when user clicks on left arrow button'
        );

        equal(nav.minVisibleBuildNumber, lastMinVisibleBuildNumber);
        equal(nav.maxVisibleBuildNumber, lastMaxVisibleBuildNumber);
    });

    test('PlanStatusHistory clickNextButton: current build is the last build', function() {
        var models = this.testHelper.generateBuilds(10, 20);

        var nav = new this.Navigator({
            bootstrap: models,
            buildNumber: 20,
            firstBuildNumber: 1,
            lastBuildNumber: 20
        });

        var lastMinVisibleBuildNumber = nav.minVisibleBuildNumber;
        var lastMaxVisibleBuildNumber = nav.maxVisibleBuildNumber;

        nav.$el.find("a.next").click();

        ok(
            !nav.clickNextButton.called,
            'clickNextButton should NOT be called when user clicks on right arrow button'
        );

        equal(nav.minVisibleBuildNumber, lastMinVisibleBuildNumber);
        equal(nav.maxVisibleBuildNumber, lastMaxVisibleBuildNumber);
    });

    test('PlanStatusHistory clickPreviousButton: fetches and decrements visible builds', function() {
        var models = this.testHelper.generateBuilds(10, 20);

        var nav = new this.Navigator({
            bootstrap: models,
            buildNumber: 15,
            firstBuildNumber: 1,
            lastBuildNumber: 30
        });
        var $previousButton = nav.$el.find("a.previous");
        var $nextButton = nav.$el.find("a.next");

        var lastMinVisibleBuildNumber = nav.minVisibleBuildNumber;
        var lastMaxVisibleBuildNumber = nav.maxVisibleBuildNumber;

        $previousButton.click();

        ok(
            nav.clickPreviousButton.called,
            'clickPreviousButton must be called when user clicks on left arrow button'
        );

        ok(
            nav.update.called,
            'update must be called when we don\'t have enough builds'
        );

        equal(nav.minVisibleBuildNumber, --lastMinVisibleBuildNumber);
        equal(nav.maxVisibleBuildNumber, --lastMaxVisibleBuildNumber);
    });

    test('PlanStatusHistory clickNextButton, clickPreviousButton', function() {
        var models = this.testHelper.generateBuilds(10, 20);

        var nav = new this.Navigator({
            bootstrap: models,
            buildNumber: 15,
            firstBuildNumber: 1,
            lastBuildNumber: 30
        });
        var $previousButton = nav.$el.find("a.previous");
        var $nextButton = nav.$el.find("a.next");

        var lastMinVisibleBuildNumber = nav.minVisibleBuildNumber;
        var lastMaxVisibleBuildNumber = nav.maxVisibleBuildNumber;

        $nextButton.click();

        ok(
            nav.clickNextButton.called,
            'clickNextButton must be called when user clicks on left arrow button'
        );

        ok(
            nav.update.called,
            'update must be called when we don\'t have enough builds'
        );

        equal(nav.minVisibleBuildNumber, ++lastMinVisibleBuildNumber);
        equal(nav.maxVisibleBuildNumber, ++lastMaxVisibleBuildNumber);
    });

    test('PlanStatusHistory getShowRightArrow', function() {
        var builds = [];
        var nav = new this.Navigator({ bootstrap: builds });
        equal(!!nav.getShowRightArrow(), false);

        builds = this.testHelper.generateBuilds(1, 10);

        nav = new this.Navigator({ bootstrap: builds, buildNumber: 10, lastBuildNumber: 10 });
        equal(!!nav.getShowRightArrow(), false);

        nav = new this.Navigator({ bootstrap: builds, buildNumber: 8, lastBuildNumber: 20 });
        equal(!!nav.getShowRightArrow(), true);

        nav = new this.Navigator({ bootstrap: builds, buildNumber: 10, lastBuildNumber: 10 });
        equal(!!nav.getShowRightArrow(), false);
    });

});
