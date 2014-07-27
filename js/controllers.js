angular.module('TIRApp.controllers', 
    [
        'TIRApp.controllers.login',
        'TIRApp.controllers.turno',
        'TIRApp.controllers.patient',
        'TIRApp.controllers.templates'
    ]).
    
    controller('GridCtrl', function ($scope, $location, TIRAPIservice) {
          $scope.totalPages = 0;
          $scope.itemCount = 0;
          $scope.headers = [
          {
            title: 'IdStudy',
            value: 'IdStudy',
            width: '50px;'
          },
          {
            title: 'Apellido',
            value: 'Patient_LastName',
            width: '300px;'
          },
          {
            title: 'Nombre',
            value: 'Patient_FirstName',
            width: '300px;'
          },
          {
            title: 'DNI',
            value: 'Patient_OtherIDs',
            width: '100px;'
          },
          {
            title: 'Procedimiento',
            value: 'ProcedureName',
            width: '100px;'
          },
          {
            title: 'Fecha',
            value: 'StudyDate',
            width: '100px;'
          },
          {
            title: 'Estado',
            value: 'Status'
          },
          {
            title: 'Accession Number',
            value: 'AccessionNumber'
          }
        ];
         
          //Will make an ajax call to fill the drop down menu in the filter of the states
          //$scope.states = TIRAPIservice.getTurnos();
         
          //default criteria that will be sent to the server
          $scope.filterCriteria = {
            pageNumber: 1,
            sortDir: 'asc',
            sortedBy: 'id'
          };
         
          //The function that is responsible of fetching the result from the server and setting the grid to the new result
          $scope.fetchResult = function () {
            return TIRAPIservice.getTurnos($scope.filterCriteria).
                then(function(response){
                  // success handler
                  $scope.turnos = response.data.data;
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
        }
);


