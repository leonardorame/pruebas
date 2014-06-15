angular.module('TIRApp.controllers', []).
    
  /* login controller */
  controller('loginController', function($scope, TIRAPIservice, $location) {
      $scope.submit = function(){
        TIRAPIservice.login($scope.username, $scope.password).
          success(function(data, status, headers, config){
            TIRAPIservice.user.name = data.fullname
            $location.path('/turnos');
          }).
          error(function(data, status, headers, config){
            console.log(status);
          });
        }
  }).

  /* Turnos controller */
  controller('turnosController', function($scope, TIRAPIservice) {
    $scope.turnos = [];
    $scope.userName = TIRAPIservice.user.name;
    TIRAPIservice.getTurnos().success(function (response) {
        //Digging into the response to get the relevant data
    });
  });

