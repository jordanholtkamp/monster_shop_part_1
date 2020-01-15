class Merchant::ItemOrdersController < Merchant::BaseController
  def update
    item_order = ItemOrder.find(params[:id])
    item = item_order.item
    item.update(inventory: item.inventory - item_order.quantity)
    item_order.update(status: 1)
    redirect_to "/merchant/orders/#{item_order.order_id}"
    flash[:success] = "You have fulfilled order for #{item.name}"
  end
end
