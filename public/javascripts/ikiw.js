var hoge;

$(function () {
    $('#edit').hide();
    $('#viewTab').click(function (e) {
	$('#view').show();
	$('#edit').hide();
	e.preventDefault();
	return false;
    });
    $('#editTab').click(function (e) {
	$('#view').hide();
	$('#edit').show();
	e.preventDefault();
	return false;
    });
    $('#edit form').submit(function (e) {
	console.log($(this).serialize());
	$.ajax({
	    url: this.action,
	    data: $(this).serialize(),
	    type: "put",
	    complete: function (xhr) {
		alert(xhr.status);
	    }
	});
	e.preventDefault();
	return false;
    });
    $('#editorMain').keydown(function (e) {
	if (e.keyCode == 86 && e.ctrlKey) {
	    alert('no!');
	    e.preventDefault();
	    return false;
	}
    });
    document.getElementById("test").onpaste = function (e) {
	hoge = e;
	if (e.clipboardData) {
	    console.log(e.clipboardData.getData('text/plain'));
	} else {
	    
	}
	return false;
    }
    /*$('#test').bind('paste', function(e) {
	
	return false;
    });*/
});
