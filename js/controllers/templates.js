angular.module('TIRApp.controllers.templates', []).
    
  /* templatesTableModel */
  controller('templatesTableModel', function($scope, $location, $modalInstance, TIRAPIservice) {
    $scope.templates = [];

    $scope.totalPages = 0;
    $scope.itemCount = 0;
    $scope.headers = [
    {
        title: 'IdPlantilla',
        value: 'IdTemplate',
        width: '50px;'
    },
    {
        title: 'Código',
        value: 'Code'
    },
    {
        title: 'Nombre',
        value: 'Name'
    }];
    //default criteria that will be sent to the server
    $scope.filterCriteria = {
        pageNumber: 1,
        sortDir: 'asc',
        sortedBy: 'id'
    };

    $scope.alert = undefined;
    $scope.closeAlert = function(){
      $scope.alert = undefined;
    };
    //The function that is responsible of fetching the result from the server and setting the grid to the new result
    $scope.fetchResult = function () {
    return TIRAPIservice.getTemplates($scope.filterCriteria).
        then(function(response){
          // success handler
          $scope.templates = response.data.data;
          $scope.totalPages = response.data.recordsTotal / 10; // page size = 10
          $scope.itemCount = response.data.recordsTotal;
        },function(response){
            // error handler
            console.log(response);
            $location.path('/login');
        });
    };

    //called when navigate to another page in the pagination
    $scope.selectPage = function (page) {
        $scope.filterCriteria.pageNumber = page;
        $scope.fetchResult();
    };

    //Will be called when filtering the grid, will reset the page number to one
    $scope.filterResult = function () {
        $scope.filterCriteria.pageNumber = 1;
        $scope.fetchResult().then(function () {
          //The request fires correctly but sometimes the ui doesn't update, that's a fix
          $scope.filterCriteria.pageNumber = 1;
        });
    };

    //call back function that we passed to our custom directive sortBy, will be called when clicking on any field to sort
    $scope.onSort = function (sortedBy, sortDir) {
        $scope.filterCriteria.sortDir = sortDir;
        $scope.filterCriteria.sortedBy = sortedBy;
        $scope.filterCriteria.pageNumber = 1;
        $scope.fetchResult().then(function () {
          //The request fires correctly but sometimes the ui doesn't update, that's a fix
          $scope.filterCriteria.pageNumber = 1;
        });
    };

    //manually select a page to trigger an ajax request to populate the grid on page load
    $scope.selectPage(1);

    $scope.ok = function(){
        $modalInstance.close($scope.template);
    };        

    $scope.cancel = function(){
        $modalInstance.dismiss('cancel');
    };        
    $scope.go = function(template){
        TIRAPIservice.getTemplate(template.IdTemplate).success(
            function(data){
                $scope.template = data;
            }
        );
    };
  }).

  /* Templates controller */
  controller('templatesController', function($filter, $scope, $location, TIRAPIservice, $modal) {
    $scope.templates = [];
    $scope.userName = TIRAPIservice.user.fullname;

    $scope.totalPages = 0;
    $scope.itemCount = 0;
    $scope.headers = [
    {
        title: 'IdPlantilla',
        value: 'IdTemplate',
        width: '50px;'
    },
    {
        title: 'Código',
        value: 'Code'
    },
    {
        title: 'Nombre',
        value: 'Name'
    }];
    //default criteria that will be sent to the server
    $scope.filterCriteria = {
        pageNumber: 1,
        sortDir: 'asc',
        sortedBy: 'id'
    };

    $scope.alert = undefined;
    $scope.closeAlert = function(){
      $scope.alert = undefined;
    };
    //The function that is responsible of fetching the result from the server and setting the grid to the new result
    $scope.fetchResult = function () {
    return TIRAPIservice.getTemplates($scope.filterCriteria).
        then(function(response){
          // success handler
          $scope.templates = response.data.data;
          $scope.totalPages = response.data.recordsTotal / 10; // page size = 10
          $scope.itemCount = response.data.recordsTotal;
        },function(response){
            // error handler
            $location.path('/login');
        });
    };

    //called when navigate to another page in the pagination
    $scope.selectPage = function (page) {
        $scope.filterCriteria.pageNumber = page;
        $scope.fetchResult();
    };

    //Will be called when filtering the grid, will reset the page number to one
    $scope.filterResult = function () {
        $scope.filterCriteria.pageNumber = 1;
        $scope.fetchResult().then(function () {
          //The request fires correctly but sometimes the ui doesn't update, that's a fix
          $scope.filterCriteria.pageNumber = 1;
        });
    };

    //call back function that we passed to our custom directive sortBy, will be called when clicking on any field to sort
    $scope.onSort = function (sortedBy, sortDir) {
        $scope.filterCriteria.sortDir = sortDir;
        $scope.filterCriteria.sortedBy = sortedBy;
        $scope.filterCriteria.pageNumber = 1;
        $scope.fetchResult().then(function () {
          //The request fires correctly but sometimes the ui doesn't update, that's a fix
          $scope.filterCriteria.pageNumber = 1;
        });
    };

    //manually select a page to trigger an ajax request to populate the grid on page load
    $scope.selectPage(1);

    // displays the div containing the editor
    // depending on template object is not undefined
    $scope.isShown = function(template){
        return template;
    };

    $scope.newTemplate = function(){
        TIRAPIservice.newTemplate().
            success(function(data, status, headers, config){
                $scope.alert = {type: 'success', msg: 'Plantilla creada exitosamente!'};
                $scope.fetchResult();
                $scope.go(data);
            }).
            error(function(data, status, headers, config){
                $scope.alert = {type: 'danger', msg: 'Error al intentar crear plantilla. COD: ' + status};
            });
    }

    $scope.go = function(template){
        TIRAPIservice.getTemplate(template.IdTemplate).success(
            function(data){
                $scope.alert = undefined;
                TIRAPIservice.template = data
                $scope.currenttpl = data;
                $scope.template = TIRAPIservice.template;
            }
        );
    };

    $scope.save = function(document) {

      TIRAPIservice.saveTemplate(document).
        success(function(data, status, headers, config){
            $scope.alert = {type: 'success', msg: 'Plantilla guardada exitosamente!'};
            var found = $filter('filter')($scope.templates, {IdTemplate: data.IdTemplate})[0];
            if (found) {
                found.Code = data.Code;
                found.Name = data.Name;
            } else {
                //console.log("not found");
            }
        }).
        error(function(data, status, headers, config){
            $scope.alert = {type: 'danger', msg: 'Error al intentar guardar plantilla. COD: ' + status};
        });
    }
});
