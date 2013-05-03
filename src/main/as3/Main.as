package {
import flash.display.Sprite;
import flash.events.Event;

[SWF(backgroundColor="#869ca7", frameRate="30", width="600", height="800")]
public class Main extends Sprite {
    public function Main() {
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, init);
    }
}
}