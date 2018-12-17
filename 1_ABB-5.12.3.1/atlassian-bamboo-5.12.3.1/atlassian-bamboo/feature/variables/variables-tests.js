define([
    'jquery',
    'feature/variables'
], function(
    $,
    variables
) {

    'use strict';

    module('Bamboo.Feature.Variables', {
        setup: function() {
            //this.$fixture = $('#qunit-fixture');
        },
        teardown: function() {
            //this.$fixture = null;
        }
    });

    test('onChangeVariableSelection', function() {
        var $fixture = $('<table><tr><td>' +
                '<select>' +
                    '<option value="foo" data-current-value="foo_value" selected></option>' +
                    '<option value="bar_PaSSword" data-current-value="bar_value"></option>' +
                '</select><input type="text">' +
            '</td></tr></table>');
        var select = $fixture.find('select');
        var input = $fixture.find('input');

        variables.VariablesTable.prototype.handleChangeVariableSelection.call(select);

        equal(
            select.prop('name'),
            'key_foo',
            'Select name property has been updated'
        );
        equal(
            input[0].outerHTML,
            '<input type="text" name="variable_foo">',
            'Input has correct type (text) and name'
        );
        equal(
            input.val(),
            'foo_value',
            'Input has correct value'
        );

        $fixture.find('select').val('bar_PaSSword').change();
        variables.VariablesTable.prototype.handleChangeVariableSelection.call(select);

        equal(
            select.prop('name'),
            'key_bar_PaSSword',
            'Select name property has been updated'
        );
        equal(
            input[0].outerHTML,
            '<input type="password" name="variable_bar_PaSSword">',
            'Input has correct type (password) and name'
        );
        equal(
            input.val(),
            'bar_value',
            'Input has correct value'
        );
    });

});
