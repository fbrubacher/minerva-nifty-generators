/**
 * @author bliff
 */
function getUrlContent(url){
    new Ajax.Request(url, {
        method: 'get',
        onSuccess: function(transport){
            var response = transport.responseText || "no response text";
            showMgLightBox(null, null, response);
        },
        onFailure: function(){
            alert('Something went wrong...')
        }
    });    
}

function showMgLightBox(w, h, content){
    if (content != undefined) {        
        $("content_preview").innerHTML = content;                
    }
    else {  
		
		
		var hb = $('body').getHeight();
		var hm = $('main').getHeight();
		var he = hm;
		
		if(hm<hb){
			he = hb;
		}
		
		
        document.getElementById('over').style.display = 'block';
        document.getElementById('fade').style.display = 'block';
		document.getElementById('fade').style.height = he;
		
                
        document.getElementById('over').style.width = w + 30;
        document.getElementById('over').style.height = h + 30;
                
        document.getElementById('over').style.marginLeft = w / 2 * -1;
        document.getElementById('over').style.marginTop = h / 2 * -1;
                
        document.getElementById('content_box').style.width = w;
        document.getElementById('content_box').style.height = h;
        
        document.getElementById('content_preview').style.width = w;
        document.getElementById('content_preview').style.height = h;                        
    }
}

function hideMgLightBox(){
    document.getElementById('over').style.display = 'none';
    document.getElementById('fade').style.display = 'none';    
    
	$("content_box").innerHTML = '<div id="content_preview"></div>';
}

document.observe("dom:loaded", function() {
  var over_div = document.createElement('div');
  Element.extend(over_div);
  over_div.addClassName('overbox');
  over_div.setAttribute('id','over');
  over_div.innerHTML = '<a href="#" class="closePreview" onclick="hideMgLightBox();" >Close</a><div id="content_box"><div id="content_preview"><image src="/images/ajax-loading.gif"></div></div>';
  
  var fade_div = document.createElement('div');
  Element.extend(fade_div);
  fade_div.addClassName('fadebox');
  fade_div.setAttribute('id','fade');
  fade_div.setAttribute('onclick','hideMgLightBox();');
  fade_div.innerHTML = '&nbsp;';
  
  $('body').appendChild(over_div);
  $('body').appendChild(fade_div);
});
