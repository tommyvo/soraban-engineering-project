class TransactionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "transactions"
  end
end
