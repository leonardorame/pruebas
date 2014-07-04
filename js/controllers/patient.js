angular.module('TIRApp.controllers.patient', []).

  /* Patients controller */
  controller('patientsController', function($scope, $location, TIRAPIservice, $modal) {
    $scope.patients = [];
    $scope.userName = TIRAPIservice.user.fullname;

    $scope.totalPages = 0;
    $scope.itemCount = 0;
    $scope.headers = [
    {
        title: 'Id. Paciente',
        value: 'IdPatient',
        width: '50px;'
    },
    {
        title: 'Nombre',
        value: 'FirstName'
    },
    {
        title: 'Apellido',
        value: 'LastName'
    },
    {
        title: 'Fecha Nac.',
        value: 'BirthDate'
    },
    {
        title: 'Sexo',
        value: 'Sex'
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
    return TIRAPIservice.getPatients($scope.filterCriteria).
        then(function(response){
          // success handler
          $scope.patients = response.data.data;
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

    $scope.go = function(patient){
        TIRAPIservice.getPatient(patient.IdPatient).success(
            function(data){
                $scope.alert = undefined;
                TIRAPIservice.patient = data
                $scope.currentpatient = data;
                $scope.patien = TIRAPIservice.patient;
            }
        );
    };
});
