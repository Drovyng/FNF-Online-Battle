package;

import flixel.FlxG;
import openfl.events.ProgressEvent;
import openfl.events.Event;
import openfl.events.ServerSocketConnectEvent;
import openfl.net.ServerSocket;
import openfl.net.Socket;

using StringTools;

@:enum
abstract OnlineUtilDataIDs(String) {
    var Initial;
    var SwitchState;
    var SelectSong;
    var GoToSong;
    var NoteHit;
    var ChangeHealth;
    var SongLoaded;
    var PlayData;
    var LuaCustom;
}

class OnlineUtil {
    public static var PING:Int = 0;
    public static var lastSend:Int = 0;
    public static var ISHOST:Bool;
    public static var MySocket:ServerSocket;
    public static var OtherSocket:Socket;
    public static var DataToSend:Array<Map<String, Dynamic>> = [];

    public static function Stop()
    {
        if (Conductor.ISONLINE)
        {
            if (MySocket != null && MySocket.listening)
            {
                MySocket.close();
            }
            if (OtherSocket != null && OtherSocket.connected)
            {
                OtherSocket.close();
            }
            MySocket = null;
            OtherSocket = null;

            ISHOST = false;
            Conductor.ISONLINE = false;
            MusicBeatState.instance.serverInfo.text = '';
            lastSend = 0;
        }
    }

    public static function StartThread(server:Bool, ip:String, ?port:Int = 8097)
    {
        Conductor.ISONLINE = true;
        ISHOST = server;

        try{
            if (server){
                StartHost(ip, port);
            }
            else{
                StartClient(ip, port);
            }
        }
        catch (exept){
            trace("Failed!");
            trace(exept.message);
            trace(exept.stack.toString());
            Stop();
        }
    }
    public static function HandleMessage(message:Array<Map<String, Dynamic>>) 
    {
        if (lastSend != 0){
            PING = Std.int(Sys.time() * 1000) - lastSend;
        }
        for (msg in message){
            HandleMsg(msg);
        }
        MusicBeatState.instance.updateSendMsgs();
        lastSend = Std.int(Sys.time() * 1000);
        OtherSocket.writeObject(DataToSend);
        OtherSocket.flush();
        DataToSend = [];
    }
    public static function AddData(data:Map<String, Dynamic>) 
    {
        DataToSend.push(data);
    }
    public static function HandleMsg(msg:Map<String, Dynamic>)
    {
        var id:OnlineUtilDataIDs = msg["id"];

        switch (id){
            case Initial:
                AddData([
                    "id" => OnlineUtilDataIDs.SwitchState,
                    "value1" => "Freeplay"
                ]);
                MusicBeatState.switchState(new FreeplayState());
                
            case SwitchState:
                switch (msg["value1"]){
                    case "Freeplay":
                        MusicBeatState.switchState(new FreeplayState());
                }
            case SelectSong:
                var state:Dynamic = FlxG.state;
                if (state is FreeplayState){
                    state.onlineP2Seleced = msg["value1"];
                    state.updateOnlineSelection();
                }
            case GoToSong:
                var state:Dynamic = FlxG.state;
                if (state is FreeplayState){
                    FreeplayState.curSelected = msg["value1"];
                    state.curDifficulty = msg["value2"];
                    state.changeSelection();
                    state.changeDiff();
                    Conductor.ISPLAYER = msg["value3"];
                    state.startSong();
                }
            case SongLoaded:
                //PlayState.timeStartCountdown = msg["value1"];
                Conductor.P2Loaded = true;
            default:
                {}
        }
        if (MusicBeatState.instance != null){
            MusicBeatState.instance.handleMsg(msg);
        }
    }
    public static function StartHost(ip:String, port:Int) 
    {
        MySocket = new ServerSocket();
        MySocket.bind(port, ip);
        MySocket.addEventListener(ServerSocketConnectEvent.CONNECT, function(event:ServerSocketConnectEvent)
        {
            trace("HOST: Client Connected!");
            OtherSocket = event.socket;
            OtherSocket.objectEncoding = 10;

            DataToSend = [
                [
                    "id" => "Initial"
                ]
            ];

            OtherSocket.writeObject(DataToSend);
            OtherSocket.flush();
            DataToSend = [];
            
            OtherSocket.addEventListener(ProgressEvent.SOCKET_DATA, function(event:ProgressEvent){
                HandleMessage(OtherSocket.readObject());
            });
            OtherSocket.addEventListener(Event.CLOSE, function(_)
            {
                Stop();
            });
        });
        MySocket.listen(1);
    }
    public static function StartClient(ip:String, port:Int) {
        OtherSocket = new Socket();
        OtherSocket.addEventListener(Event.CONNECT, function(_)
        {
            trace("CLIENT: Connected!");
        });
        OtherSocket.addEventListener(Event.CLOSE, function(_)
        {
            Stop();
        });
        
        OtherSocket.addEventListener(ProgressEvent.SOCKET_DATA, function(event:ProgressEvent){
            HandleMessage(OtherSocket.readObject());
        });
        OtherSocket.objectEncoding = 10;
        OtherSocket.connect(ip, port);
        OtherSocket.objectEncoding = 10;
    }
}
