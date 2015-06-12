angular.module('TIRApp.controllers.template', []).
  /* Template controller */
  controller('templateController', function($scope, $location, TIRAPIservice, $modalInstance, template) {
    $scope.userName = TIRAPIservice.user.fullname;
    $scope.template = template;

    $scope.getEditorConfig = function(element) {
      var cfg = {}
      cfg.removePlugins = 'elementspath';
      cfg.resize_enabled = false;
      cfg.toolbarGroups = [
            { name: 'clipboard',   groups: [ 'clipboard', 'undo' ] },			// Group's name will be used to create voice label.
            { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] }
          ];
      return cfg;
    };

    $scope.keyUp = function(event) {
      var keyCode = event.data.$.keyCode;
      switch( keyCode) {
          case 27: { $scope.cancel(); break; }
      }
    };

    $scope.alert = undefined;
    $scope.closeAlert = function(){
      $scope.alert = undefined;
    };

    $scope.ok = function(){
        $modalInstance.close($scope.template);
    };        

    $scope.cancel = function(){
        $modalInstance.dismiss('cancel');
    };        

    TIRAPIservice.getTemplate(template.IdTemplate).success(
        function(data){
            $scope.alert = {type: 'success', msg: 'Plantilla ' + data.IdTemplate + ' cargada exitosamente.'};
            TIRAPIservice.template = data;
            $scope.template = data;
        }
    ).error(
        function(data, status, headers, config){
            alert(data);
            alert(status);
        }
    );

});
