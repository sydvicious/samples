from django.http import HttpResponse


def main_index_view(request):
    body = '''<html><body>
    <H1>Welcome to the Bone Jarring Games and Software Service page.</H1>

    <div id = "main-text-body">
    <p>
    This page is the main landing page for the Bone Jarring Games Service page.For more information about the company,
    please visit <a href = "http://www.bonejarring.com" Bone Jarring Games and Software.> </a>
    </p>
    </div>

    <div id = "construction">
    <p>
    This page is under construction.Please be patient. At some point, we will be taking signups for our mailing lists, betas, and announcements.
    </p>
    </div>

    <div id = "copyright">
    <p><p>
    Copyright(c) 2016 Bone Jarring Games and Software. All rights reserved.
    </p></p>
    </div >
</body></html>
'''
    return HttpResponse(body)