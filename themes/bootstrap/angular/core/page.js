
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

        var cleanList = function(list) {
            return _.uniq(_.compact(list));
        };

        var filterArray = function(configKey) {
            return cleanList(_.map($scope.data.parsed, function(item) {
                var key = item[$scope.config.keys[configKey]];
                return key ? key.basicInfo : null;
            }));
        };

        var orderArray = function(configKey) {
            return _.groupBy($scope.data.parsed, function(value) {
                var testValue = value[$scope.config.keys[configKey]];
                if(!testValue) {
                    return;
                } else {
                    return testValue.basicInfo;
                }
            })
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

            $scope.categories = filterArray('category');
            $scope.mainTypes = filterArray('mainType');
            $scope.subTypes = filterArray('subType');

            $scope.mainBySub = orderArray('mainType');
            $scope.categoryByMain = orderArray('category');
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