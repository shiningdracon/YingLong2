var dragonComicView = (function() {
	var $ = function(id){return document.getElementById(id)};

	var canvas = new fabric.Canvas('c', null);

	var imgHeight, imgWidth;

	function resizeCanvas() {
		containerWidth = document.getElementsByClassName("column-left")[0].clientWidth;
		if (canvas.width != containerWidth) {
			var width = (containerWidth < imgWidth) ? containerWidth : imgWidth;
			var scaleMultiplier = width / imgWidth;
			if (scaleMultiplier > 1) scaleMultiplier = 1;
			canvas.setWidth(imgWidth * scaleMultiplier);
			canvas.setHeight(imgHeight * scaleMultiplier);
			canvas.setZoom(scaleMultiplier);
		}
	}

	function deserialization() {
		canvas.loadFromJSON($('json').value, function(o, object) {
			img = canvas.backgroundImage;
			imgWidth = img.width, imgHeight = img.height;
			resizeCanvas();
			canvas.renderAll.bind(canvas);
		});
	}

	function makeUnselectable() {
		var objs = canvas.getObjects();
		for (var obj of objs) {
			obj.selectable = false;
		}
	}

	window.onresize = resizeCanvas;

	deserialization();
	makeUnselectable();
})();
