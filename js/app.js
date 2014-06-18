angular.module('TIRApp', [
  'TIRApp.services',
  'TIRApp.controllers',
  'ngRoute'
]).

run(['TIRAPIservice','$location' ,function(TIRAPIservice, $location){
    if(!TIRAPIservice.user.id){
        if(!TIRAPIservice.retrieveUserInfo())
            $location.path('/login');
    }
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
