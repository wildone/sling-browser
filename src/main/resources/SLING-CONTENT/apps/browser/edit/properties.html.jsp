<%@page import="javax.jcr.PropertyType"%>
<%@page import="javax.jcr.nodetype.PropertyDefinition"%>
<%@page import="javax.jcr.security.Privilege"%>
<%@page import="javax.jcr.security.AccessControlManager"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="javax.jcr.Value"%>
<%@page import="javax.jcr.Property"%>
<%@page import="javax.jcr.PropertyIterator"%>
<%@page import="javax.jcr.Session"%>
<%@page session="false" contentType="text/html; charset=utf-8"
	trimDirectiveWhitespaces="true"%>
<%@taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<sling:defineObjects />
<c:set var="staticRoot" value="/apps/browser/static" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
<title>${currentNode.name}</title>
 <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <link href="${staticRoot}/bootstrap-3.3.0/css/bootstrap.min.css" rel="stylesheet" media="screen">
 <style>
 
 .table>thead>tr>th {
 	border-top:none;
 }
 .container {
 	margin-right: 0;
	margin-left: 0;
	background-color: #fff;
	border-color: #ddd;
	border-width: 1px;
	border-radius: 4px 4px 0 0;
	-webkit-box-shadow: none;
	box-shadow: none;
 }
 
 .readonly {
 	opacity:0.6;
 }
 
 .value-edit {
 	display:none;
 }
 
 .value-edit textarea {
 	width: 95%;
	resize: vertical;
 }
 
 .editing {
 	-webkit-user-select:none;
 	user-select:none;
 }
 .editing .value-edit {
 	display:block;
 }
 .editing .value-display {
 	display:none;
 }
 
 .divclearable {
    border: 1px solid #888;
    display: -moz-inline-stack;
    display: inline-block;
    zoom:1;
    *display:inline;
    padding-right:5px;
    vertical-align:middle;
}
  
a.clearlink {
    background: url("close-button.png") no-repeat scroll 0 0 transparent;
    background-position: center center;
    cursor: pointer;
    display: -moz-inline-stack;
    display: inline-block;
    zoom:1;
    *display:inline;
    height: 12px;
    width: 12px;
    z-index: 2000;
    border: 0px solid;
}

.screenLock {
	position: fixed;
	width: 100%;
	height: 100%;
	min-height: 100%;
	max-height: 100%;
	top: 0;
	right: 0;
	padding: 0;
	margin: 0;
	background: rgba(255, 255, 255, 0.8);
	overflow-y: hidden;
	overflow-x: hidden;
	-moz-user-select: none;
	-webkit-user-select: none;
	-ms-user-select: none;
	user-select: none;
	z-index: -1; 
	line-height:normal;
	letter-spacing:normal;
}

body.lock .screenLock {
	z-index:100;
}

body.lock .value-edit {
	z-index:101;
}

.glyphicon {
	cursor:pointer;
}
.glyphicon:hover {
	color:red;
}

.glyphicon-ok:hover {
	color:green;
}

.value-edit:before {
	content: attr(title);
	display: inline-block;
	font-weight:bold;
	font-size:1.1em;
	color: #476C8A;
}


.value-edit {
	background-color: rgba(255, 255, 255, 0.90);
	border: 1px solid #999;
	box-shadow: 3px 5px 20px 2px #ddd;
	box-sizing: border-box;
	border-radius: 5px;
	padding:5px;
}


 </style>
  <script type="text/javascript" src="${staticRoot}/jquery-2.1.1.min.js"></script>
</head>
<body>
	<div class="container">
		<table class="table table-condensed">
			<tbody>
				<thead>
					<tr>
						<th>Name</th>
						<th>Type</th>
						<th>Value</th>
						<%--><th>Status</th> --%>
						<th>Action</th>
					</tr>
				</thead>
						
			<%
				PropertyIterator properties = currentNode.getProperties();
				String primaryType = currentNode.getProperty("jcr:primaryType").getString();
				String resourceType = resource.getResourceType();
				String path = currentNode.getPath();
				if (properties != null) {
					Session session = currentNode.getSession();
					while (properties.hasNext()) {
						Property p = properties.nextProperty();
						PropertyDefinition propertyDefinition = p.getDefinition();
						String name = p.getName();
						String[] values = null;
						
						String readonlyClass = (propertyDefinition.isProtected() || name.equals("jcr:data")) ? "readonly" : "";
						if (p.isMultiple()) {
							Value v[] = p.getValues();
							values =  new String[v.length];
							for (int i = 0; i < v.length; i++) {
								values[i] = v[i].getString();
							}
							
						} else {
							values = new String[1];
							values[0] = name.equals("jcr:data") ? "binary" : p.getString();
						}
						String propertyType = PropertyType.nameFromValue(p.getType());
			%>
				<tr class="<%=readonlyClass%> alert" data-name="<%=name%>" data-type="<%=propertyType %>" data-multiple="<%=p.isMultiple() %>" >
					<td><%=name%></td>
					<td><%=propertyType %><%= propertyDefinition.isMultiple()?"[]": "" %></td>
					<td>
						<div class="value-display"><%= StringUtils.join(values,", ") %></div>
						<div class="value-edit" title="<%=name%>">
							<% for (String value:values) { %>
							<span><%=value%></span>
							<% } %>
						</div>
					</td>
					
					<td class="actions">
						<% if (!(propertyDefinition.isProtected() || name.equals("jcr:data"))) { %>
							<span class="glyphicon glyphicon-trash" title="delete this property"></span> 
						<% } %>
					</td>
				</tr>
			<%
					}
				}
			%>
			</tbody>
		</table>
	</div>
	<div style="display:none">
		<form id="propertyFormTmpl"  method="post" action="${resource.path}" enctype="multipart/form-data">
			<%--
			<input type="hidden" name=":redirect" value="${slingRequest.requestURL}?editType=${param.editType}" />
			<input type="hidden" name=":errorpage" value="${slingRequest.requestURL}?editType=${param.editType}" />
			 --%>
			<div class="clear"></div>
			<span class="glyphicon glyphicon-ok" data-action="ok" title="save changes"></span> <span class="glyphicon glyphicon-remove"  data-action="cancel" title="cancel"></span>
		</form>
	</div>
	<script>
		var propertyFormTmpl = $('#propertyFormTmpl').clone().removeAttr('id');
		$('tr:not(.readonly)').on('dblclick', function() {
			var _self = $(this);
			_self.toggleClass('editing');
			if (window.parent && window.parent.document) {
				$( window.parent.document).find('body').toggleClass('lock');
			}
			$('body').toggleClass('lock');
			
			if (!_self.data('renderForm')) {
				_self.data('renderForm',true);
				createEditPanel(_self);
			}
			if (_self.is('.editing')) {
				var valueEdit = _self.find('.value-edit')
				var clientRect = valueEdit[0].getBoundingClientRect();
				valueEdit.css({position:'fixed',width:clientRect.width , left:clientRect.left, top:clientRect.top});
			}
		})
		// JCR PropertyDefinition String,Date,Binary,Double,Long,Boolean,Name,Path,Reference,Undefined
		function createEditPanel(trElement) {
			var name = trElement.data('name');
			var type = trElement.data('type');
			var isMultiple =  trElement.data('multiple')
			var valueEdit = trElement.find('.value-edit');
			var propertyForm = propertyFormTmpl.clone();
			var out = [];
			if (!isMultiple) {
				var val = valueEdit.find('span').text();
				if (type == 'Boolean') {
					out.push('<input type="checkbox" name="'+name+'" value="'+val+'" checked="'+val+'" />');
				} else if (type == 'Reference') {
					//TODO
				} else if (type == 'Date') {
					//TODO
				} else if (type == 'Name') {
					//TODO
				} else if (type == 'Long'){
					out.push('<input type="text" required pattern="[0-9]+" name="'+name+'" value="'+val+'" />');
				} else {
					out.push('<textarea name="'+name+'">'+val+'</textarea>');
				}
			} else {
				
			}
			valueEdit.on('click', function(e) {
				if (e.target.nodeName == 'SPAN') {
					var $target = $(e.target);
					action = $target.data('action');
					if (action == 'cancel') {
						$target.closest('tr').trigger('dblclick');
					} else if (action == 'ok') {
						var $form = $target.closest('form');
						var isValid;
						$form.on('submit', function(e) {
							e.preventDefault();
							var field = $form.find('input[pattern]')[0];
							console.log(field);
							if (typeof field.willValidate !== 'undefined') {
								field.checkValidity();
								isValid = field.validity.valid;
								console.log(isValid);
							}
							return false;
						});
						$form.submit();
						/*
						$.post($form.attr('action'), $form.serialize())
						.done(function(data) {
							var dataHtml = $(data);
							var status = dataHtml.find('#Status').text();
							var message = dataHtml.find('#Message').text();
							if (status == '200' && message == 'OK') {
								valueEdit.prev().text($form.find('[name='+name+']').val());
								valueEdit.closest('tr').trigger('dblclick').addClass('alert-success').fadeOut(500).fadeIn(1000,function() {$(this).removeClass('alert-success')});
							}
						}).fail(function(jqXHR, textStatus, errorThrown) {
							console.log(textStatus,errorThrown,jqXHR);
						})
						*/
						//$target.closest('form').submit();
					}
				} 
			})
		 	valueEdit.empty().append(propertyForm.prepend(out.join('')));
		}
		
	 	function openEdit(event) {
	 		event.preventDefault();
	 		var field = $(this).attr('data-field');
	 		var fieldValue = dataJson[field];
	 		var fieldSet = $("#dialog-edit fieldset")
	 		fieldSet.empty();
	 		$("#dialog-edit").dialog('option','title','FIELD: '+field);
	 		if (fieldValue instanceof Array) {
	 			for (var i in fieldValue) {
	 				$('<input type="text" />').attr('name',field).attr('value',fieldValue[i]).appendTo(fieldSet);
	 			}
	 			fieldSet.children().each(function() {	
				$(this).css({'border-width': '0px', 'outline': 'none', 'border-spacing':'5px'})
					.wrap('<div class="divclearable"></div>')
					.parent()
					.attr('class', $(this).attr('class') + ' divclearable')
					.append('<a class="clearlink" href="#"></a>');
			
				$('.clearlink')
					.attr('title', 'Click to clear this textbox')
					.click(function(event) {
						event.preventDefault();
						$(this).parent().remove();
					});
				  });
	 		} else if (fieldValue.indexOf('<') > -1) {
	 			var textarea  = $('<textarea></textarea>').attr('name',field).attr('value',fieldValue).appendTo(fieldSet);
	 			textarea.wysiwyg({
					rmUnusedControls: true,
					controls: {
						bold: { visible : true },
						html: { visible : true },
						italic: {visible: true},
						insertOrderedList: { visible: true},
						insertUnorderedList: {visible: true},
						undo: {visible: true},
						redo: {visible: true},
						removeFormat: { visible : true }
					}
				});
	 		} else {
	 			$('<input type="text"/>').attr('name',field).attr('value',fieldValue).appendTo(fieldSet);
	 		}
	 		
	 		 $("#dialog-edit").dialog('open');
	 	}
	 	
		
	
	</script>
	<div class="screenLock"></div>
</body>
</html>