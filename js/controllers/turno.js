angular.module('TIRApp.controllers.turno', []).

  /* Turno controller */
  controller('turnoController', function($window, $scope, $routeParams, TIRAPIservice, $modal) {
      $scope.study = TIRAPIservice.study;
      $scope.userName = TIRAPIservice.user.fullname;
      $scope.alert = undefined;
      $scope.mySound = null;
      $scope.progressValue = 0;
      $scope.progressMax = 100;

      function timecode(ms) {
        var hms = {
          h: Math.floor(ms/(60*60*1000)),
          m: Math.floor((ms/60000) % 60),
          s: Math.floor((ms/1000) % 60),
          ms: Math.floor((ms%1000)/100)
        };
        var tc = []; // Timecode array to be joined with '.'

        if (hms.h > 0) {
          tc.push(hms.h);
        }

        tc.push((hms.m < 10 && hms.h > 0 ? "0" + hms.m : hms.m));
        tc.push((hms.s < 10 ? "0" + hms.s : hms.s));
        tc.push(hms.ms);

        return tc.join(':');
      }

      TIRAPIservice.getStudy($routeParams.id).success(
            function(data){
                TIRAPIservice.study = data
                $scope.study = TIRAPIservice.study;
                $scope.alert = undefined;
            }
      );

      $scope.activate = function(study){
          TIRAPIservice.study.IdStatus = study.IdStatus;
      };

      $scope.closeAlert = function(){
        $scope.alert = undefined;
      };
            
      $scope.initAudio = function(){
        soundManager.setup({
            url: '../swf/',
            onready: function(){
                var fileName = $scope.study.IdStudyProcedure + '.wav';
                $scope.mySound = soundManager.createSound({
                    url: '/cgi-bin/tir/audio/' + fileName
                });
                $scope.mySound.load({
                    onload: function(success){
                        $scope.progressMax = Math.floor($scope.mySound.duration);
                    }
                });
            }
        });
      }

      $scope.saveAudio = function(){
        var fileName = $scope.study.IdStudy + '.wav';
        var aData = null;

        Recorder.upload({
          url: "/cgi-bin/tir/audio/" + fileName,
          success: function(){
            alert("your file was uploaded!");
          }
        });
      }

      $scope.openViewer = function() {
        $window.open("http://192.168.1.124/masterview/mv.jsp?user_name=url&password=url1234&accession_number=" + TIRAPIservice.study.AccessionNumber, "Carestream", "height=600, width=800");
      }

      $scope.startRecording = function(){
        var fileName = $scope.study.IdStudy + '.wav';
        Recorder.record({
            start: function(){
            },
            progress: function(milliseconds){
                document.getElementById("time").innerHTML = timecode(milliseconds);
            }
        });
      }

      $scope.begin = function() {
        $scope.mySound.pause();
        $scope.mySound.setPosition(0);
        document.getElementById("time").innerHTML = timecode($scope.mySound.position);
      }

      $scope.end = function() {
        $scope.mySound.pause();
        $scope.mySound.setPosition($scope.mySound.duration);
        document.getElementById("time").innerHTML = timecode($scope.mySound.position);
      }

      $scope.rew = function() {
        $scope.mySound.setPosition($scope.mySound.position - 1000);
        document.getElementById("time").innerHTML = timecode($scope.mySound.position);
      }

      $scope.ff = function() {
        if($scope.mySound.position + 500 < $scope.mySound.duration) {
            $scope.mySound.setPosition($scope.mySound.position + 1000);
            document.getElementById("time").innerHTML = timecode($scope.mySound.position);
        }
      }

      $scope.pause = function() {
        $scope.mySound.pause();
      }

      $scope.stop = function() {
        $scope.mySound.pause();
      }

      $scope.play = function() {
        $scope.mySound.play({
            multiShot: false,
            whileplaying: function() {
                document.getElementById("time").innerHTML = timecode($scope.mySound.position);
            }
        });
      }

      $scope.selectTemplate = function(){
            $modal.open({
                controller: 'templatesTableController',
                templateUrl: 'partials/templatestable.html'
            }).result.then(function(template){
                if(template)
                    $scope.study.Report = template.Template;
            });
      };

      $scope.statusList = function(){
            $modal.open({
                controller: 'studystatusTableController',
                templateUrl: 'partials/statustable.html',
                resolve: {
                    study: function(){
                        return $scope.study;
                    }
                }
            }).result.then(function(status){
                // nothing to be done.
            });
      };

      $scope.save = function(document) {
          TIRAPIservice.saveStudy(document).
            success(function(data, status, headers, config){
                $scope.alert = {type: 'success', msg: 'Documento guardado exitosamente!'};
            }).
            error(function(data, status, headers, config){
                $scope.alert = {type: 'danger', msg: 'Error al intentar guardar documento. COD: ' + status};
            })
      };

      $scope.print = function() {
           var dataset = JSON.stringify(TIRAPIservice.study);
           var body = $('body');
           var hiddenForm = "<form action='/cgi-bin/tir/print' method='POST'><input type='hidden' name='dataset' value='" + dataset + "'/ ><button id='submitPrint' type='submit'></button></form>";
           body.append(hiddenForm);
           $('#submitPrint').click();
           $('#submitPrint').remove();
          
           // este método sólo funciona en Firefox/Chrome
          /*TIRAPIservice.printStudy().
            success(function(response, status, headers, config){
                $scope.alert = {type: 'success', msg: 'Documento impreso exitosamente!'};
                var file = new Blob([response], {type: 'application/pdf'});
                var fileURL = URL.createObjectURL(file);
                window.open(fileURL);
            }).
            error(function(response, status, headers, config){
                $scope.alert = {type: 'danger', msg: 'Error al intentar imprimir documento. COD: ' + status};
            })
        */
      };
  }).

  /* Turnos controller */
  controller('turnosController', function($scope, $location, $modal, TIRAPIservice) {
    $scope.turnos = [];
    $scope.userName = TIRAPIservice.user.fullname;
    $scope.alert = undefined;
    $scope.totalPages = 0;
    $scope.itemCount = 0;
    $scope.headers = [
      {
        title: 'IdStudy',
        value: 'IdStudy',
        width: '50px;',
        align: 'right'
      },
      {
        title: 'Paciente',
        value: 'Patient_LastName',
        width: '200px;',
        align: 'left'
      },
      {
        title: 'DNI',
        value: 'Patient_OtherIDs',
        width: '100px;',
        align: 'left'
      },
      {
        title: 'Procedimiento',
        value: 'ProcedureName',
        width: '50px;',
        align: 'left'
      },
      {
        title: 'Fecha',
        value: 'StudyDate',
        width: '100px;',
        align: 'left'
      },
      {
        title: 'Estado',
        value: 'Status',
        align: 'left'
      },
      {
        title: 'Accession Number',
        value: 'AccessionNumber',
        align: 'left'
      },
      {
        title: 'Usuario Actual',
        value: 'UserName',
        align: 'left'
      },
      {
        title: 'Informó',
        value: 'Report_UserName',
        align: 'left'
      },
      {
        title: 'Audio',
        value: 'HasWav',
        align: 'center'
      }
    ];
     
    //Will make an ajax call to fill the drop down menu in the filter of the states
    //$scope.states = TIRAPIservice.getTurnos();
     
    //default criteria that will be sent to the server
    $scope.filterCriteria = {
      pageNumber: 1,
      sortDir: 'asc',
      sortedBy: 'id',
      UserName: TIRAPIservice.user.name
    };
     
    //The function that is responsible of fetching the result from the server and setting the grid to the new result
    $scope.fetchResult = function () {
        return TIRAPIservice.getTurnos($scope.filterCriteria).
            then(function(response){
              // success handler
              $scope.turnos = response.data.data;
              $scope.totalPages = response.data.recordsTotal / 10; // page size = 10
              $scope.itemCount = response.data.recordsTotal;
              $scope.turnos = response.data.data;
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

    $scope.go = function(study){
        TIRAPIservice.study = study;
        var url = '/turnos/' + study.IdStudyProcedure;
        $location.path(url);
    };

    $scope.select = function(study){
        $scope.currentstudy = study;
    };
    $scope.closeAlert = function(){
      $scope.alert = undefined;
    };

    $scope.toTranscriptionist = function(turnos){
        var lChecked = false;
        $scope.alert = undefined;
        angular.forEach(turnos, function(turno){
            lChecked = lChecked || turno.checked;
        });
        if(!lChecked) {
            $scope.alert = {type: 'danger', msg: 'Debe seleccionar al menos un estudio.'};
            return;
        };

        $modal.open({
            controller: 'usersTableController',
            templateUrl: 'partials/userstable.html'
        }).result.then(function(user){
            if(user){
                // traverse checked studies
                var studies = [];
                for (var i in turnos){
                    if(turnos[i].checked)
                        studies.push(turnos[i].IdStudy);
                }
                TIRAPIservice.assignStudiesToUser(studies, user);
                $scope.fetchResult().then(function (){
                        $scope.filterCriteria.pageNumber = 1;
                    }
                );
            }
        });
    };

    $scope.changeStatus = function(turnos){
        var lChecked = false;
        $scope.alert = undefined;
        angular.forEach(turnos, function(turno){
            lChecked = lChecked || turno.checked;
        });
        if(!lChecked) {
            $scope.alert = {type: 'danger', msg: 'Debe seleccionar al menos un estudio.'};
            return;
        };

        $modal.open({
            controller: 'statusTableController',
            templateUrl: 'partials/statustable.html'
        }).result.then(function(status){
            if(status){
                // traverse checked studies
                var studies = [];
                for (var i in turnos){
                    if(turnos[i].checked)
                        studies.push(turnos[i].IdStudy);
                }
                TIRAPIservice.changeStatus(studies, status);
                $scope.fetchResult().then(function (){
                        $scope.filterCriteria.pageNumber = 1;
                    }
                );
            }
        });
    };
  });
