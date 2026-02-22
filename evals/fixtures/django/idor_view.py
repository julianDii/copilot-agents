# Fixture: IDOR — object fetched without ownership check
# Expected finding: Blocker — any authenticated user can access any order by ID

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from .models import Order
from .serializers import OrderSerializer


class OrderDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        order = get_object_or_404(Order, pk=pk)  # ← no user= or tenant= scope
        serializer = OrderSerializer(order)
        return Response(serializer.data)

    def delete(self, request, pk):
        order = get_object_or_404(Order, pk=pk)  # ← same issue on delete
        order.delete()
        return Response(status=204)

