angular.module('TIRApp.controllers.insertupdatetpl', []).
    
  controller('insertUpdateTplController', function($scope, $location, $modalInstance, TIRAPIservice) {
    $scope.insertTemplate = "insert";
    $scope.ok = function(){
        $modalInstance.close($scope.insertTemplate);
    };        

    $scope.cancel = function(){
        $modalInstance.dismiss('cancel');
    };        

    $scope.go = function(insertTemplate){
            $scope.insertTemplate = insertTemplate;
    };
});
