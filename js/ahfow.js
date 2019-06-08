$(document).ready(function() {
	$("article img").addClass("img-responsive");
    $('.wrapper a[href^="http://"],.wrapper a[href^="https://"]')
    	.not('a:has(img)')
        .attr('target','_blank')
        .append(' <i class="fas fa-external-link-alt"></i>')
    ;
});
