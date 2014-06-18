angular.module('TIRApp', [
  'TIRApp.services',
  'TIRApp.controllers',
  'ngRoute'
]).

run(['TIRAPIservice', '$rootScope', '$location', function(TIRAPIservice, $rootScope, $route, $location){
    // Adds Header and Footer on route change success
    $rootScope.$on('$stateChangeSuccess', function (ev, current, prev) {
        $rootScope.flexyLayout = function(partialName) { 
            console.log(partialName);
            return current.$$route[partialName] 
        };
    });

    $rootScope.$on( "$routeChangeStart", function(event, next, current){
        if(!TIRAPIservice.user.id){
            TIRAPIservice.retrieveUserInfo().
                success(function(data){
                    TIRAPIservice.user.id = data.id;
                    TIRAPIservice.user.name = data.name;
                    TIRAPIservice.user.fullname = data.fullname;
                    TIRAPIservice.user.profile = data.profile;
                    TIRAPIservice.user.idprofessional = data.idprofessional;
                    console.log(TIRAPIservice.user);
                    //$location.path('/turnos');
                    //$route.reload();
                }).
                error(function(data, status, headers, config){
                    $location.path('/login');
                });
        }
    });
}]).

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

angular.module('TIRApp').directive('onBlurChange', function ($parse) {
  return function (scope, element, attr) {
    var fn = $parse(attr['onBlurChange']);
    var hasChanged = false;
    element.on('change', function (event) {
      hasChanged = true;
    });
 
    element.on('blur', function (event) {
      if (hasChanged) {
        scope.$apply(function () {
          fn(scope, {$event: event});
        });
        hasChanged = false;
      }
    });
  };
});

angular.module('TIRApp').directive('onEnterBlur', function() {
  return function(scope, element, attrs) {
    element.bind("keydown keypress", function(event) {
      if(event.which === 13) {
        element.blur();
        event.preventDefault();
      }
    });
  };
});
