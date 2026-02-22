# Fixture: N+1 query — iterating queryset without select_related
# Expected finding: Major — each order.user access fires a separate DB query

from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Order


class OrderListView(APIView):
    def get(self, request):
        orders = Order.objects.all()  # ← no select_related('user')
        data = []
        for order in orders:
            data.append({
                "id": order.id,
                "total": str(order.total),
                "user_email": order.user.email,  # ← hits DB for every order
            })
        return Response(data)

