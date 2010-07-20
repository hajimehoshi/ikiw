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
});
