require 'pry'

class ProductsController < ApplicationController
  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
  end

  def quote
    ur = Uber::RUSH.new

    pickup_obj = Uber::PICKUP

    dropoff_obj = {
      location: {
        address: params[:address],
        city: params[:city],
        state: "New York",
        postal_code: params[:postal_code],
        country: "US",
      }
    }

    response = ur.delivery_quote(pickup_obj, dropoff_obj)

    respond_to do |format|
      format.html
      format.js do
        @quote = response["quotes"][0]
        @dropoff = dropoff_obj
      end
    end
  end

  def order
      # Amount in cents
      @amount = 500

      customer = Stripe::Customer.create(
        :email => params[:email],
        :card  => params[:stripeToken]
      )

      ur = Uber::RUSH.new
      pickup_obj = Uber::PICKUP

      dropoff_obj = {
        location: {
          address: params[:address],
          city: params[:city],
          state: "New York",
          postal_code: params[:postal_code],
          country: "US",
        },
        contact: {
          first_name: params[:first_name],
          last_name: params[:last_name],
          email: params[:email],
          phone: {
            number: "+1" + params[:number],
            sms_enabled: true
          }
        }
      }

      items = [
        {
          title: params[:title],
          quantity: 1,
          price: params[:price]
        }
      ]

      response = ur.create_delivery(items, pickup_obj, dropoff_obj)
      @amount = ((params[:price].to_f + response["fee"]) * 100).to_i
      @time = response["dropoff"]["eta"] + response["pickup"]["eta"]

      binding.pry

      charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount      => @amount,
        :description => params[:title],
        :currency    => 'usd'
      )

      redirect_to done_path(amount: @amount, time: @time)

    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to :back

    end

  def done
    # code for confirmation page
  end
end
