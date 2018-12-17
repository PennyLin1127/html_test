define([
    'jquery',
    'underscore',
    'widget/result-summary',
    'widget/result-summaries'
], function(
    $,
    _,
    ResultSummary,
    ResultSummaries
) {

    'use strict';

    module('Bamboo.ResultSummaries', {
        setup: function() {
            // fake all XHR
            this.server = sinon.useFakeXMLHttpRequest();
            this.requests = [];

            // catch all requests
            this.server.onCreate = _.bind(function(xhr) {
                this.requests.push(xhr);
            }, this);

            this.createModel = function(buildNumber, isActive) {
                return new ResultSummary({
                    buildNumber: buildNumber,
                    active: isActive
                });
            };
        },
        teardown: function() {
            this.server.restore();
        }
    });

    test('Id of model is build number', function() {
        var model = this.createModel(123);

        equal(model.id, 123, 'id should be equal to build number');
    });

    test('getMinimumBuildNumber', function() {
        var model1 = this.createModel(123),
            model2 = this.createModel(125);

        var collection = new ResultSummaries([]);

        equal(collection.getMinimumBuildNumber(), null, 'Empty collection returns null minimum build number');

        collection = new ResultSummaries([model1]);

        equal(collection.getMinimumBuildNumber(), 123, 'Collection of 1 returns build number');

        collection = new ResultSummaries([model1, model2]);

        equal(collection.getMinimumBuildNumber(), 123, 'Collection of 2 returns build number');
    });

    test('getIndexOfBuildNumber', function() {
        var model1 = this.createModel(123),
            model2 = this.createModel(125);

        var collection = new ResultSummaries([]);

        equal(collection.getIndexOfBuildNumber(123), -1, 'Empty collection returns -1');

        collection = new ResultSummaries([model1]);

        equal(collection.getIndexOfBuildNumber(123), 0, 'Collection of 1 returns result');
        equal(collection.getIndexOfBuildNumber(125), -1, 'Collection of 1 returns result');

        collection = new ResultSummaries([model1, model2]);

        equal(collection.getIndexOfBuildNumber(123), 0, 'Collection of 2 returns result');
        equal(collection.getIndexOfBuildNumber(125), 1, 'Collection of 2 returns result');
    });

    test('getMaximumBuildNumber', function() {
        var model1 = this.createModel(123),
            model2 = this.createModel(125),
            model3 = this.createModel(127, true);

        var collection = new ResultSummaries([]);

        equal(collection.getMaximumBuildNumber(), null, 'Empty collection returns null');

        collection = new ResultSummaries([model1]);

        equal(collection.getMaximumBuildNumber(), 123, 'Collection of 1 returns result');

        collection = new ResultSummaries([model3]);

        equal(collection.getMaximumBuildNumber(), 127, 'Collection of 1 returns result');

        collection = new ResultSummaries([model1, model2]);

        equal(collection.getMaximumBuildNumber(), 125, 'Collection of 2 returns result');

        collection = new ResultSummaries([model1, model2, model3]);

        equal(collection.getMaximumBuildNumber(), 127, 'Collection of 3 returns result');
    });

    test('purgeActiveBuilds', function() {
        var model1 = this.createModel(123),
            model2 = this.createModel(125),
            model3 = this.createModel(127, true);

        var collection = new ResultSummaries([]);
        collection.purgeActiveBuilds();
        equal(collection.length, 0, 'Empty collection doesnt change');

        collection = new ResultSummaries([model1]);
        collection.purgeActiveBuilds();
        equal(collection.length, 1, 'Collection with no active builds doesnt change');

        collection = new ResultSummaries([model3]);
        collection.purgeActiveBuilds();
        equal(collection.length, 0, 'Collection with active builds changes');

        collection = new ResultSummaries([model1, model2, model3]);
        collection.purgeActiveBuilds();
        equal(collection.length, 2, 'Collection with active builds changes');
    });

    test('getPreviousBuildNumber', function() {
        var model1 = this.createModel(123),
            model2 = this.createModel(125),
            model3 = this.createModel(127);

        var collection = new ResultSummaries([]);

        equal(collection.getPreviousBuildNumber(123), null, 'Empty collection returns null');

        collection = new ResultSummaries([model1]);

        equal(collection.getPreviousBuildNumber(123), null, 'Collection of 1 returns null');
        equal(collection.getPreviousBuildNumber(125), null, 'Collection of 1 returns null');

        collection = new ResultSummaries([model1, model2]);

        equal(collection.getPreviousBuildNumber(123), null, 'First element returns null');
        equal(collection.getPreviousBuildNumber(125), 123, 'Second element returns correct result');
        equal(collection.getPreviousBuildNumber(127), null, 'Missing element returns null');

        collection = new ResultSummaries([model1, model2, model3]);

        equal(collection.getPreviousBuildNumber(123), null, 'First element returns null');
        equal(collection.getPreviousBuildNumber(125), 123, 'Second element returns first element');
        equal(collection.getPreviousBuildNumber(127), 125, 'Third element returns second element');
        equal(collection.getPreviousBuildNumber(129), null, 'Missing element returns null');
    });

    test('getNextBuildNumber', function() {
        var model1 = this.createModel(123),
            model2 = this.createModel(125),
            model3 = this.createModel(127);

        var collection = new ResultSummaries([]);

        equal(collection.getNextBuildNumber(123), null, 'Empty collection returns null');

        collection = new ResultSummaries([model1]);

        equal(collection.getNextBuildNumber(123), null, 'Collection of 1 returns null');
        equal(collection.getNextBuildNumber(125), null, 'Collection of 1 returns null');

        collection = new ResultSummaries([model1, model2]);

        equal(collection.getNextBuildNumber(123), 125, 'First element returns second element');
        equal(collection.getNextBuildNumber(125), null, 'Second element returns null');
        equal(collection.getNextBuildNumber(127), null, 'Missing element returns null');

        collection = new ResultSummaries([model1, model2, model3]);

        equal(collection.getNextBuildNumber(123), 125, 'First element returns second element');
        equal(collection.getNextBuildNumber(125), 127, 'Second element returns third element');
        equal(collection.getNextBuildNumber(127), null, 'Third element returns null');
        equal(collection.getNextBuildNumber(129), null, 'Missing element returns null');
    });

});
