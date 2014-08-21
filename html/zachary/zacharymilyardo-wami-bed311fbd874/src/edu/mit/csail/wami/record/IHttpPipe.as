package edu.mit.csail.wami.record
{
  public interface IHttpPipe
  {
    import flash.utils.ByteArray;
    import edu.mit.csail.wami.utils.StateListener;

    //Performs upload the recording to the remote server.
    function performPost():void;
    
    function setListener(listener:StateListener):void;
    
    //Pipe Functions
    function write(bytes:ByteArray):void;
    function close():void;

    //Get Recording to be uploaded(for sample playback)
    function getAudio():ByteArray;
  }
}
