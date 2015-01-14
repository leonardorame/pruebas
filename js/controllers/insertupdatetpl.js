angular.module('TIRApp.controllers.insertupdatetpl', []).
    
  controller('insertUpdateTplController', function($scope, $location, $modalInstance, TIRAPIservice) {
    $scope.insertTemplate = {
        type: "update"
    };
    $scope.ok = function(){
        $modalInstance.close($scope.insertTemplate);
    };        

    $scope.cancel = function(){
        $modalInstance.dismiss('cancel');
    };        
});
