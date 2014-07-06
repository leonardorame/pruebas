angular.module('TIRApp.controllers.turno', []).

  /* Turno controller */
  controller('turnoController', function($scope, $routeParams, TIRAPIservice, $modal) {
      $scope.study = TIRAPIservice.study;
      $scope.userName = TIRAPIservice.user.fullname;
      $scope.alert = undefined;
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
         try {
             // webkit shim
             window.AudioContext = window.AudioContext || window.webkitAudioContext;
             navigator.getUserMedia = ( navigator.getUserMedia ||
             navigator.webkitGetUserMedia ||
             navigator.mozGetUserMedia ||
             navigator.msGetUserMedia);
             window.URL = window.URL || window.webkitURL;
             
             audio_context = new AudioContext;
             //alert('navigator.getUserMedia ' + (navigator.getUserMedia ? 'available.' : 'not present!'));
         } catch (e) {
             alert('No web audio support in this browser!');
         }
         
         navigator.getUserMedia({audio: true}, startUserMedia, function(e) {
             alert('No live audio input: ' + e);
         });
      }

      function startUserMedia(stream) {
        var input = audio_context.createMediaStreamSource(stream);
        //alert("input sample rate " +input.context.sampleRate);
        
        input.connect(audio_context.destination);
        //alert('Input connected to audio context destination.');
        
        recorder = new Recorder(input);
        //alert('Recorder initialised.');
      }

      $scope.startRecording = function(button){
        recorder && recorder.record();
        button.disabled = true;
        alert('Recording...');
      }

      $scope.stopRecording = function(button) {
        recorder && recorder.stop();
        button.disabled = true;
        alert('Stopped recording.');
        
        // create WAV download link using audio data blob
        createDownloadLink();
        
        recorder.clear();
      }

      $scope.playbackRecorderAudio = function (recorder, context) {
        recorder.getBuffer(function (buffers) {
          var source = context.createBufferSource();
          source.buffer = context.createBuffer(1, buffers[0].length, 44100);
          source.buffer.getChannelData(0).set(buffers[0]);
          source.buffer.getChannelData(0).set(buffers[1]);
          source.connect(context.destination);
          source.noteOn(0);
        });
      }

      $scope.selectTemplate = function(){
            $modal.open({
                controller: 'templatesTableModel',
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
          TIRAPIservice.printStudy().
            success(function(response, status, headers, config){
                $scope.alert = {type: 'success', msg: 'Documento impreso exitosamente!'};
                var file = new Blob([response], {type: 'application/pdf'});
                var fileURL = URL.createObjectURL(file);
                window.open(fileURL);
            }).
            error(function(response, status, headers, config){
                $scope.alert = {type: 'danger', msg: 'Error al intentar imprimit documento. COD: ' + status};
            })
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
  });
