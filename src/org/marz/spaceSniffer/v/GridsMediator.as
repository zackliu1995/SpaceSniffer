package org.marz.spaceSniffer.v {
	import flash.geom.Rectangle;

	import org.marz.spaceSniffer.c.ExploreFileTree;
	import org.marz.spaceSniffer.c.Refresh;
	import org.marz.sys.OnEnterFrame;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import org.marz.spaceSniffer.m.vo.FileTree;
	import org.marz.spaceSniffer.m.GridsProxy;
	import org.marz.spaceSniffer.v.vo.GridRenderer;

	public class GridsMediator extends Mediator {
		private static const NAME:String = 'Grids';

		public static const SHOW:String = 'show';

		public static const UPDATE:String = 'update';

		private var count:int;

		public function GridsMediator() {
			super(NAME, null);

			facade.registerProxy(new GridsProxy);
			OnEnterFrame.addFunc('refresh', Refresh.doRefresh);
		}

		override public function handleNotification(notification:INotification):void {
			switch (notification.getName()) {
				case SHOW:
					GridsProxy.instance.fileTree = notification.getBody() as FileTree;
					GridsProxy.instance.fileTreeArr = GridsProxy.instance.fileTree.getDirectories();
					dataChanged(GridsProxy.instance.fileTree);
					sendNotification(ExploreFileTree.EXLORE_FILE_TREE);
					break;
				case UPDATE:
					if (GridsProxy.instance.fileTree) {
						if (GridsProxy.instance.dataChanged) {
							if (count == 24) {
								count = 0;
								dataChanged(GridsProxy.instance.fileTree);
								GridsProxy.instance.dataChanged = false;
							}
							count++;
						}
						sendNotification(ExploreFileTree.EXLORE_FILE_TREE);
					}
				default:
					break;
			}
		}

		private function dataChanged(ft:FileTree):void {
			Global.stage.removeChildren();

			var gridRenderer:GridRenderer = new GridRenderer;
			Global.stage.addChild(gridRenderer);
			var rect:Rectangle = new Rectangle(0, 0, Global.stage.stageWidth, Global.stage.stageHeight);
			gridRenderer.depth = 0;
			gridRenderer.update(ft, rect);
		}

		override public function listNotificationInterests():Array {
			return [SHOW, UPDATE];
		}

		public static function get instance():GridsMediator {
			return GridsMediator(Facade.getInstance().retrieveMediator(NAME));
		}
	}
}
