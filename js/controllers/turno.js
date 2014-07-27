angular.module('TIRApp.controllers.turno', []).

  /* Turno controller */
  controller('turnoController', function($window, $scope, $routeParams, TIRAPIservice, $modal) {
      $scope.study = TIRAPIservice.study;
      $scope.userName = TIRAPIservice.user.fullname;
      $scope.alert = undefined;

      function timecode(ms) {
        var hms = {
          h: Math.floor(ms/(60*60*1000)),
          m: Math.floor((ms/60000) % 60),
          s: Math.floor((ms/1000) % 60)
        };
        var tc = []; // Timecode array to be joined with '.'

        if (hms.h > 0) {
          tc.push(hms.h);
        }

        tc.push((hms.m < 10 && hms.h > 0 ? "0" + hms.m : hms.m));
        tc.push((hms.s < 10 ? "0" + hms.s : hms.s));

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
          Recorder.initialize({
            workerPath: "../js/recorderWorker.js",
            swfSrc: "../swf/recorder.swf"
          });
      }

      $scope.saveAudio = function(){
        var fileName = $scope.study.IdStudy + '.wav';
        Recorder.upload({
          url: "/cgi-bin/tir/audio",
          params: {
            "FileName": fileName
          },
          success: function(){
            alert("your file was uploaded!");
          }
        });
      }

      $scope.openViewer = function() {
        $window.open("http://192.168.1.124/masterview/mv.jsp?user_name=url&password=url1234&accession_number=" + TIRAPIservice.study.AccessionNumber, "Carestream", "height=600, width=800");
      }

      $scope.startRecording = function(){
        Recorder.record({
          start: function(){
            //alert("recording starts now. press stop when youre done. and then play or upload if you want.");
          },
          progress: function(milliseconds){
            document.getElementById("time").innerHTML = timecode(milliseconds);
          }
        });
      }

      $scope.pauseRecording = function() {
        Recorder.stop();
      }

      $scope.stopRecording = function() {
        Recorder.stop();
      }

      $scope.play = function() {
        Recorder.stop();
        Recorder.play({
            progress: function(miliseconds){
                document.getElementById("time").innerHTML = timecode(miliseconds);
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
  controller('turnosController', function($scope, $location, TIRAPIservice) {
    $scope.turnos = [];
    $scope.userName = TIRAPIservice.user.fullname;

    $scope.go = function(study){
        TIRAPIservice.study = study;
        var url = '/turnos/' + study.IdStudy;
        $location.path(url);
    };

    $scope.toTranscriptionist = function(turnos){
        console.log(turnos);
    };
  });
