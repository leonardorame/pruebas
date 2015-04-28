angular.module('TIRApp.controllers.diagnostico', []).
    
  controller('diagnosticoController', function($scope, $location, study, $modalInstance, TIRAPIservice) {
    $scope.study = study;

    $scope.cancel = function(){
        $modalInstance.dismiss('cancel');
    };        
});
