angular.module('TIRApp.controllers.login', []).
  /* default login controller */
  controller('loginController', function($scope, TIRAPIservice, $location) {
      $scope.$watch('loginForm', function(frm) {
        if(frm){
            frm.$setPristine();
            frm.username = "";
        }
      }, true);
  
      $scope.submit = function(){
        TIRAPIservice.login($scope.username, $scope.password).
          success(function(data, status, headers, config){
            TIRAPIservice.user.id = data.id;
            TIRAPIservice.user.name = data.name;
            TIRAPIservice.user.fullname = data.fullname;
            TIRAPIservice.user.profile = data.profile;
            TIRAPIservice.user.idprofessional = data.idprofessional;
            $location.path('/turnos');
          }).
          error(function(data, status, headers, config){
            alert(status);
          });
        }
}).

  /* popup login controller */
  controller('popupLoginController', function($scope, TIRAPIservice, $location, $modalInstance) {
      $scope.$watch('loginForm', function(frm) {
        if(frm){
            frm.$setPristine();
            frm.username = "";
        }
      }, true);

      $scope.ok = function(loginForm){
        TIRAPIservice.login(loginForm.user.$modelValue, loginForm.password.$modelValue).
          success(function(data, status, headers, config){
            TIRAPIservice.user.id = data.id;
            TIRAPIservice.user.name = data.name;
            TIRAPIservice.user.fullname = data.fullname;
            TIRAPIservice.user.profile = data.profile;
            TIRAPIservice.user.idprofessional = data.idprofessional;
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
