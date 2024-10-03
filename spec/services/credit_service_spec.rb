# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreditService do
  let(:subject) { described_class.new }
  let(:current_user) { create(:user) }
  let(:receiver) { create(:user) }
  let(:params) {
    {
      type: CreditService::TYPE_CREDIT,
      amount: 2000,
      source_wallet_id: current_user.wallet.id,
    }
  }

  context 'errors' do
    context 'when amount credit <= 0' do
      it 'should raise error' do
        params[:amount] = 0
        expect { subject.execute(current_user, params) }.to raise_error(ApiExceptions::BadRequestError) do |error|
          expect(error.message).to eq("Invalid Data")
          expect(error.detail).to eq("Amount should not be less than 0")
        end
      end
    end

    context 'wallet' do
      context 'source wallet not found' do
        let(:id_wallet_not_found) { 9999 }
        let(:params) {
          {
            type: 'transfer',
            amount: 2000,
            source_wallet_id: id_wallet_not_found,
            target_wallet_id: receiver.wallet.id
          }
        }
        it 'should raise error' do
          expect { subject.execute(current_user, params) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  context 'success' do
    let(:amount) { 2000 }
    let(:params) {
      {
        type: CreditService::TYPE_CREDIT,
        amount: amount,
        source_wallet_id: current_user.wallet.id,
        target_wallet_id: receiver.wallet.id
      }
    }

    before do
      current_user.wallet.update_columns(balance: amount)
      create(:transaction, source_wallet: current_user.wallet, amount: amount, type: Credit)
    end

    it 'should balance updated' do
      subject.execute(current_user, params)
      total_amount = TransactionRepository.new.get_total_balance(current_user.wallet.id)

      expect(total_amount).to eq(amount + params[:amount].to_f)
    end
  end
end
