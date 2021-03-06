angular.module('TIRApp.controllers.login', []).
  /* default login controller */
  controller('loginController', function($scope, TIRAPIservice, $location, $cookieStore) {
      $scope.$watch('loginForm', function(frm) {
        if(frm){
            frm.$setPristine();
            frm.username = "";
        }
      }, true);
          
      $scope.submit = function(){
        TIRAPIservice.login($scope.username, $scope.password).
          success(function(data, status, headers, config){
            $cookieStore.put('user_', data);
            $location.path('/turnos');
          }).
          error(function(data, status, headers, config){
            alert(status);
          });
        }
}).

  /* popup login controller */
  controller('popupLoginController', function($scope, TIRAPIservice, $location, $modalInstance, $cookieStore) {
      $scope.$watch('loginForm', function(frm) {
        if(frm){
            frm.$setPristine();
            frm.username = "";
        }
      }, true);

      $scope.ok = function(loginForm){
        TIRAPIservice.login(loginForm.user.$modelValue, loginForm.password.$modelValue).
          success(function(data, status, headers, config){
            $cookieStore.put('user_', data);
            $modalInstance.close();
          }).
          error(function(data, status, headers, config){
            alert(status);
          });
      };        

      $scope.cancel = function(){
          $modalInstance.dismiss('cancel');
      };        
});
