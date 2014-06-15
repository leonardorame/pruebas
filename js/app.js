angular.module('TIRApp', [
  'TIRApp.services',
  'TIRApp.controllers',
  'ngRoute'
]).

/* directiva main-menu */
directive("mainMenu", function(){
    return {
        restrict: 'A',
        templateUrl: 'partials/menu.html',
        scope: true,
        transclude: false
    }
}).

config(['$routeProvider', function($routeProvider) {
  $routeProvider.
	when("/login", {templateUrl: "partials/login.html", controller: "loginController"}).
	when("/turnos", {templateUrl: "partials/turnos.html", controller: "turnosController"}).
	when("/turnos/:id", {templateUrl: "partials/turno.html", controller: "turnoController"}).
	otherwise({redirectTo: '/login'});
}]);
