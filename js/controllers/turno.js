angular.module('TIRApp.controllers.turno', []).

  /* Turno controller */
  controller('turnoController', function($window, $scope, $routeParams, TIRAPIservice, $modal) {
      $scope.study = TIRAPIservice.study;
      $scope.userName = TIRAPIservice.user.fullname;
      $scope.alert = undefined;
      $scope.mySound = null;
      $scope.progressValue = 0;
      $scope.progressMax = 100;
      $scope.player = {};

      function secondstotime(secs)
      {
            var t = new Date(1970,0,1);
            t.setSeconds(secs);
            var s = t.toTimeString().substr(0,8);
            if(secs > 86399)
                s = Math.floor((t - Date.parse("1/1/70")) / 3600000) + s.substr(2);
            return s;
      }

      $scope.keyUp = function(event) {
        var keyCode = event.data.$.keyCode;
        switch( keyCode) {
            case 113: { $scope.player.status = ''; $scope.$apply(); break; }
            case 115: { $scope.player.status = ''; $scope.$apply(); break; }
        }
      };

      $scope.keyDown = function(event) {
        var keyCode = event.data.$.keyCode;
        switch( keyCode) {
            case 113: { $scope.rew(); break; }
            case 114: { 
                if($scope.playing)
                    $scope.pause();
                else
                    $scope.play(); 
                break; 
            }
            case 115: { $scope.ff(); break; }
        }
      };

      $scope.keyPress = function(event) {
        //console.log('keyPress');
      };

      TIRAPIservice.getStudy($routeParams.id).success(
            function(data){
                TIRAPIservice.study = data
                $scope.study = TIRAPIservice.study;
                $scope.alert = undefined;
                // recien despues de 
                // haber cargado los datos
                // del estudio llamamos a initAudio
                initAudio();
            }
      );

      $scope.activate = function(study){
          TIRAPIservice.study.IdStatus = study.IdStatus;
      };

      $scope.closeAlert = function(){
        $scope.alert = undefined;
      };
        
      function initAudio(){
        var audio5js = new Audio5js({
            format_time: false,
            throw_errors: true,
            swf_path: '../swf/audio5js.swf',
            use_flash: true,
            ready: function() {
                var audio = this;
                var fileName = $scope.study.IdStudy + '.wav';
                this.on('timeupdate', function(pos, dur){
                    document.getElementById("time").innerHTML = secondstotime(pos);
                }, this);
                this.on('canplay', function(){
                    $scope.mySound = audio;
                });
                this.on('error', function(error){
                    console.log(error.message);
                });

                this.on('seeking', function(error){
                });

                this.on('seeked', function(error){
                });

                this.load('/cgi-bin/tir/audio/' + fileName);
                this.pause();
            }
        });
      }
    
      $scope.$on('$destroy', function leaving(){
            $scope.mySound.destroy();
        });
            
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
        var ip = '';
        if (location.hostname == "192.168.1.121")
            ip = '192.168.1.124';
        else
            ip = '186.153.167.91';

        $window.open("http://" + ip + "/masterview/mv.jsp?user_name=url&password=url1234&accession_number=" + TIRAPIservice.study.AccessionNumber, "Carestream", "height=600, width=800");
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
        $scope.player.status = 'begin';
        $scope.mySound.pause();
        $scope.mySound.seek(0);
        $scope.playing = false;
      }

      $scope.end = function() {
        $scope.player.status = 'end';
        $scope.mySound.pause();
        $scope.mySound.seek($scope.mySound.duration);
        $scope.playing = false;
      }

      $scope.rew = function() {
        $scope.player.status = 'rw';
        if($scope.mySound.position - 0.5 > 0)
            $scope.mySound.seek($scope.mySound.position - 0.5);
        $scope.playing = false;
      }

      $scope.ff = function() {
        $scope.player.status = 'ff';
        if($scope.mySound.position + 0.5 < $scope.mySound.duration)
            $scope.mySound.seek($scope.mySound.position + 0.5);
        $scope.playing = false;
      }

      $scope.pause = function() {
        $scope.player.status = 'pause';
        $scope.mySound.pause();
        $scope.playing = false;
      }

      $scope.stop = function() {
        $scope.player.status = 'pause';
        $scope.mySound.pause();
        $scope.playing = false;
      }

      $scope.play = function() {
        $scope.player.status = 'play';
        $scope.mySound.play();
        $scope.playing = true;
      }

      $scope.selectTemplate = function(){
            $modal.open({
                controller: 'templatesTableController',
                templateUrl: 'partials/templatestable.html'
            }).result.then(function(template){
                if(template){
                    this.template = template;
                    $modal.open({
                        controller: 'insertUpdateTplController',
                        templateUrl: 'partials/insertupdatetpl.html',
                        resolve: {
                            template: function(){
                                return this.template;
                            }
                        }
                    }).result.then(function(tipo){
                        if(tipo.type == 'insert') {
                          $scope.study.Report = $scope.study.Report + '<br>' + this.template.Template;
                        } else {
                          $scope.study.Report = this.template.Template;
                        }
                    });
                }
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

      $scope.diagnostico = function(){
            $modal.open({
               controller: 'diagnosticoController',
                templateUrl: 'partials/diagnostico.html',
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
                if(status = '401'){ 
                    $modal.open({
                        controller: 'popupLoginController',
                        templateUrl: 'partials/loginPopup.html'
                    }).result.then(function(){
                        $scope.alert = {type: 'danger', msg: 'Por favor guarde nuevamente el documento.'};
                    });
                }
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
        title: 'Modalidad',
        value: 'Modality',
        width: '50px;',
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
      },
      {
        title: 'Sucursal',
        value: 'Sucursal',
        align: 'center'
      }
    ];
     
    //default criteria that will be sent to the server
    $scope.filterCriteria = TIRAPIservice.studiesDefaultFilters;
     
    //The function that is responsible of fetching the result from the server and setting the grid to the new result
    $scope.fetchResult = function () {
        TIRAPIservice.studiesDefaultFilters = $scope.filterCriteria;
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
        TIRAPIservice.studiesDefaultFilters.pageNumber = page;
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
    $scope.selectPage(TIRAPIservice.studiesDefaultFilters.pageNumber);

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
            controller: 'studystatusTableController',
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
