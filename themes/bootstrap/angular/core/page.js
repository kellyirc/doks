
angular.module('doks', ['mgcrea.ngStrap', 'ui.router', 'ui.select', 'ncy-angular-breadcrumb'])

    .config(['$stateProvider', '$locationProvider', '$urlRouterProvider', function($stateProvider, $locationProvider, $urlRouterProvider) {
        $locationProvider.hashPrefix('!');

        $urlRouterProvider.otherwise('/');

        $stateProvider
            .state('root', {
                url: '/',
                controller: 'Content',
                templateUrl: 'views/main-content.html',
                ncyBreadcrumb: {
                    label: 'Home'
                }
            })
            .state('hasCategory', {
                url: '/:category',
                controller: 'Content',
                templateUrl: 'views/main-content.html',
                ncyBreadcrumb: {
                    parent: 'root',
                    label: '{{urlParams.category}}'
                }
            })
            .state('hasMainType', {
                url: '/:category/:mainType',
                controller: 'Content',
                templateUrl: 'views/main-content.html',
                ncyBreadcrumb: {
                    parent: 'hasCategory',
                    label: '{{urlParams.mainType}}'
                }
            })
            .state('hasSubType', {
                url: '/:category/:mainType/:subType',
                controller: 'Content',
                templateUrl: 'views/main-content.html',
                ncyBreadcrumb: {
                    parent: 'hasMainType',
                    label: '{{urlParams.subType}}'
                }
            })
    }])

    .controller('Page', ['$scope', '$http', function($scope, $http) {
        $scope._ = window._;

        //no need to display these, they are templated elsewhere
        $scope.ignoredProperties = ['lineNumber', 'endLineNumber', 'filePath', 'fileName', 'desc', '$$hashKey'];

        $scope.propsAsArray = function(obj) {
            return _(obj)
                .omit($scope.ignoredProperties)
                .keys()
                .sortBy()
                .map(function(key) {
                    var ret = [];
                    if(_.isArray(obj[key])) {
                        _.each(obj[key], function(item) {
                            ret.push({name: key, value: item});
                        })
                    } else {
                        ret.push({name: key, value: obj[key]});
                    }
                    return ret;
                })
                .flatten()
                .value()
        };

        var cleanList = function(list) {
            return _.uniq(_.compact(list));
        };

        var filterArray = function(dataSet, configKey) {
            return cleanList(_.map(dataSet, function(item) {
                var key = item[$scope.config.keys[configKey]];
                return key ? key.basicInfo : null;
            }));
        };

        var orderArray = function(mainKey, subKey) {
            var keys = $scope.config.keys;
            var hasMainKey = function(value) { return value[keys[mainKey]]; };
            var hasSubKey = function(value) { return value[keys[subKey]]; };
            var data = _.filter($scope.data.parsed, hasMainKey);

            return _(data)
                .map(function(value) { return value[keys[mainKey]].basicInfo; })
                .uniq()
                .sortBy()
                .map(function(category) {
                    var matchesCategory = function(value) { return value[keys[mainKey]].basicInfo === category; };
                    return {
                        name: category,
                        children: _(data)
                            .filter(hasSubKey)
                            .filter(matchesCategory)
                            .map(function(value) { return value[keys[subKey]].basicInfo; })
                            .uniq()
                            .sortBy()
                            .map(function(objectKey) {
                                return {
                                    name: objectKey,
                                    children: _(data)
                                        .filter(hasSubKey)
                                        .filter(matchesCategory)
                                        .filter(function(value) { return value[keys[subKey]].basicInfo === objectKey; })
                                        .each(function(value) { value._props = $scope.propsAsArray(value); })
                                        .value()
                                };
                            })
                            .value()
                    }
                })
                .value();
        };

        $http.get('config.json')
            .success(function(data) {
                $scope.config = data;

                $http.get('output.json')
                    .success(function(data) {
                        $scope.data = data;
                    });
            });

        $scope.$watch('data', function(newVal, oldVal) {
            if(newVal === oldVal) return;

            $scope.categories = filterArray($scope.data.parsed, 'category');
            $scope.mainTypes = filterArray($scope.data.parsed, 'mainType');
            $scope.subTypes = filterArray($scope.data.parsed, 'subType');

            $scope.orderedData = orderArray('category', 'mainType');
        });
    }])

    .controller('Content', ['$scope', '$stateParams', function($scope, $stateParams) {
        $scope.urlParams = $stateParams;
        $scope._ = window._;

        $scope.contentFilter = {};

        if($scope.urlParams.category) $scope.contentFilter[$scope.$parent.config.keys.category] = $scope.urlParams.category;
        if($scope.urlParams.mainType) $scope.contentFilter[$scope.$parent.config.keys.mainType] = $scope.urlParams.mainType;
        if($scope.urlParams.subType)  $scope.contentFilter[$scope.$parent.config.keys.subType]  = $scope.urlParams.subType;

        $scope.getLowestSort = function() {
            return function(object) {
                var value = object[$scope.$parent.config.keys.subType];
                return value ? value.basicInfo : null;
            };
        };

        $scope.getParentSort = function() {
            return function(object) {
                var value = object[$scope.$parent.config.keys.mainType];
                return value ? value.basicInfo : null;
            };
        };
    }]);