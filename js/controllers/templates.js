angular.module('TIRApp.controllers.templates', []).
    
  controller('templatesTableController', function($scope, $location, $modalInstance, TIRAPIservice) {
    $scope.user = TIRAPIservice.user();
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
    },
    {
        title: 'Modalidad',
        value: 'Modality'
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
                $scope.currenttpl = data;
            }
        );
    };
  }).

  /* Templates controller */
  controller('templatesController', function($filter, $scope, $location, TIRAPIservice, $modal) {
    $scope.templates = [];
    $scope.TIRAPIservice = TIRAPIservice;

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
    },
    {
        title: 'Modalidad',
        value: 'Modality'
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
                $scope.alert = {type: 'danger', msg: 'Error al intentar crear plantilla. COD: ' + status + ' - Probablemente el nombre y/o código esten duplicados (buscar NEW-CODE).'};
            });
    }
    
    $scope.selectTemplate = function(aTemplate){
        $scope.currenttpl = aTemplate;
    }

    $scope.openTemplate = function(aTemplate){
        $scope.currenttpl = aTemplate;
        $modal.open({
            controller: 'templateController',
            templateUrl: 'partials/template.html',
            windowClass: 'modal-huge',
            resolve: {
                template: function(){
                    return $scope.currenttpl;
                }
            }
        }).result.then(function(template){
            if(template){
                $scope.template = template;
                $scope.currenttpl = template;
                $scope.save();
            }
        });
    };

    $scope.save = function() {
      TIRAPIservice.saveTemplate($scope.template.Template).
        success(function(data, status, headers, config){
            $scope.alert = {type: 'success', msg: 'Plantilla ' + data.Code + ' guardada exitosamente!'};
            var found = $filter('filter')($scope.templates, {IdTemplate: data.IdTemplate})[0];
            if (found) {
                found.Code = data.Code;
                found.Name = data.Name;
                found.Title = data.Title;
                found.Modality = data.Modality;
            } else {
            }
        }).
        error(function(data, status, headers, config){
            $scope.alert = {type: 'danger', msg: 'Error al intentar guardar plantilla. COD: ' + status};
        });
    }
});
