# Fixture: @csrf_exempt without justification on session-auth endpoint
# Expected finding: Major — removes CSRF protection from a state-changing endpoint
#                   that uses session authentication
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required
from django.http import JsonResponse
import json
@csrf_exempt          # <- removes CSRF protection; endpoint uses session auth
@login_required
def transfer_funds(request):
    if request.method == "POST":
        data = json.loads(request.body)
        amount = data["amount"]
        to_account = data["to_account"]
        # perform transfer...
        return JsonResponse({"status": "ok"})
