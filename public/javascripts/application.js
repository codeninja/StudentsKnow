// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function toggle_instructions(){
	Element.toggle('instructions');
}


function toggle_category(category){
	Element.toggle(category);
}

function toggle_upload_category(model,name,text){
	button_div = $(name);
	button_desc = $('category_description');
	category_field = $(model + '_category');
	if (button_div != null && button_desc != null && category_field != null) {
		if (button_div.classNames().include("category_selected")) {
			button_div.removeClassName("category_selected");
			button_desc.innerHTML = 'Select a category from above.';
			category_field.value = '';
		}
		 else
		{
			$$('a.category_selector').each(function(x){x.removeClassName("category_selected")})
			button_div.addClassName("category_selected");
			button_desc.innerHTML = text;
			category_field.value = name;
		}
		validate_name_and_description_and_category(model);
	}
}

function validate_name_and_description_and_category(model_name){
	name_field = $(model_name + '_name');
	desc_field = $(model_name + '_description');
	category_field = $(model_name + '_category');
	submit_button = $(model_name + '_submit');
	if (name_field != null && desc_field != null && submit_button != null && category_field != null) {
		if (name_field.value != '' && desc_field.value != '' && category_field.value != '') {
			submit_button.enable();
		} else
		{
			submit_button.disable();
		}
		
	}
}

function expand_collapse(div_id,link_id){
	link = $(link_id);
	div = $(div_id);
	if (link.className == 'collapsed') {
		link.removeClassName('collapsed');
		link.addClassName('expanded')
		link.innerHTML = 'collapse';
		div.show();
	} else {
		link.removeClassName('expanded');
		link.addClassName('collapsed')
		link.innerHTML = 'expand'
		div.hide();
	}
}



function animate_upload_continue_button(){
	$('continue_button_message').innerHTML = 'PLEASE WAIT FOR UPLOAD TO FINISH:';
	$('continue_button_progress').show();
	$('continue_button_animation').show();	
}

function update_upload_continue_button_progress(){
	o = $$('div.progressBarInProgress p')[0];
	if (o != null) {
		$('continue_button_progress').innerHTML = o.innerHTML;
	}
}

function upload_completed(){
	if ($('continue_button') != null) {
	$('continue_button_progress').innerHTML = '';
	$('continue_button_animation').hide();
	$('continue_button_message').innerHTML = 'CONTINUE';
	$("asset_info").show(); }
}

function hide_continue_button(){
	cb = $('continue_button');
	if (cb != null) { 
		if (!(cb.hasClassName('disabled_button'))) { cb.hide(); }
	}
}



function select_all(obj){
	obj.focus(); obj.select();
}

// function show_cle_intro_text(){
// 	intro = $('cle_intro');
// 	if (!(intro.visible())) {
// 		$$('#cle_text p').each(function(x){x.hide();});
// 		$('cle_intro').show();
// 	}
// }
// 
// function show_cle_text(id) {
// 	$$('#cle_text p').each(function(x){x.hide();});
// 	$('cle_' + id).show();
// }
// 
// function cle_timeout(e){
// 	timeout = 10000
// 	// Code taken from http://www.quirksmode.org/js/events_mouse.html#mouseover
// 	// Thank you to the author.
// 	if (!e) var e = window.event;
// 	var tg = (window.event) ? e.srcElement : e.target;
// 	if (tg.nodeName != 'DIV') return;
// 	var reltg = (e.relatedTarget) ? e.relatedTarget : e.toElement;
// 	while (reltg != tg && reltg.nodeName != 'BODY')
// 		reltg= reltg.parentNode
// 	if (reltg== tg) return;
// 	setTimeout("show_cle_intro_text()", timeout);	
// }

function switch_welcome_bg(f) {
	$('welcome_box').setStyle({backgroundImage: 'url(/images/' + f + ')'})
}


function open_popup(url) {
	window.open(url, '_blank', 'scrollbars=yes,menubar=no,height=600,width=1000,resizable=yes,toolbar=no,location=no,status=no');
}

function toggle_submit(){
	sb = $('submit_button');
	if (sb.disabled == true) {
		sb.disabled = false;
	} else {
		sb.disabled = true;
	}
}

var default_start_instructions = 'Click a category name to browse OR enter keywords to search.';

function start_category_rollover(description){
	$('get_started_description').innerHTML = description;
}

function start_category_rolloff() {
	$('get_started_description').innerHTML = '';
}

function add_ad_popup_behaviors(){
	$$('div.ad_div').each(function(x){
		add_ad_popup(x);
	});
}

function add_ad_popup(o){
	links = $$('div#' + o.id + ' a');
	if (links.size() > 0) {
		link = links[0].href;
		if (link.length > 5) {
			o.observe(o, onClick,open_popup(link));
		}
	}
}

function toggle_comment_reply_link(id) {
	$('comment_' + id + '_reply_link').toggle();
	$('comment_' + id + '_hide_reply_link').toggle();
	$('comment_' + id + '_reply').toggle();
}

function toggle_categories() {
	new_status = ($('check_all').checked == true);
	$$('ul#edit_feed_category_list li.checked_category input').each(function(x){x.checked = new_status });;
}

var CLERotate = Class.create();
CLERotate.prototype = {
	initialize: function(container_id,time_interval) {
		this.container = $(container_id);
		this.labels = ['create','learn','earn'];
		this.label_interval_time = time_interval * 1000;
		this.label_interval = null;
		this.current_index = 0;
		this.setup();
		this.start_rotate();
	},
	setup: function() {
		this.container.setStyle({backgroundImage: 'url(/images/create.png)'});
	},
	show: function(label) {
		this.stop_rotate();
		this.current_index = this.labels.indexOf(label);
		this.show_current();
	},
	show_current: function() {
		current_label = this.labels[this.current_index];
		img_url = 'url(/images/' + current_label + '.png)'
		this.container.setStyle({backgroundImage: img_url})
	},
	show_next: function() {
		if (this.current_index == (this.labels.length - 1)) {
			this.current_index = 0;
		} else {
			this.current_index += 1;
		}
		this.show_current();
	},
	start_rotate: function() {
		this.label_interval = setInterval(this.show_next.bind(this), this.label_interval_time);
	},
	stop_rotate: function() {
		clearInterval(this.label_interval);
	}
}
