# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DebitService do
  let(:subject) { described_class.new }
  let(:current_user) { create(:user) }
  let(:receiver) { create(:user) }
  let(:params) {
    {
      type: DebitService::TYPE_DEBIT,
      amount: 2000,
      source_wallet_id: current_user.wallet.id,
    }
  }

  context 'errors' do
    context 'when amount debit <= 0' do
      it 'should raise error' do
        params[:amount] = 0
        expect { subject.execute(current_user, params) }.to raise_error(ApiExceptions::BadRequestError) do |error|
          expect(error.message).to eq("Invalid Data")
          expect(error.detail).to eq("Amount should not be less than 0")
        end
      end
    end

    context 'wallet' do
      context 'source wallet from current user not belongings' do
        let(:params) {
          {
            type: 'transfer',
            amount: 2000,
            source_wallet_id: receiver.wallet.id,
            target_wallet_id: current_user.wallet.id
          }
        }

        it 'should raise error' do
          expect { subject.execute(current_user, params) }.to raise_error(ApiExceptions::BadRequestError) do |error|
            expect(error.message).to eq("Invalid Data")
            expect(error.detail).to eq("User dont have access to this wallet")
          end
        end
      end

      context 'when balance wallet not meet' do
        it 'should raise error' do
          expect { subject.execute(current_user, params) }.to raise_error(ApiExceptions::BadRequestError) do |error|
            expect(error.message).to eq("Invalid Data")
            expect(error.detail).to eq("Insufficient funds")
          end
        end
      end

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
        type: DebitService::TYPE_DEBIT,
        amount: amount,
        source_wallet_id: current_user.wallet.id,
      }
    }

    before do
      current_user.wallet.update_columns(balance: amount)
      create(:transaction, source_wallet: current_user.wallet, amount: amount, type: Credit)
    end

    it 'should balance updated' do
      subject.execute(current_user, params)
      total_amount = TransactionRepository.new.get_total_balance(current_user.wallet.id)

      expect(total_amount).to eq(amount - params[:amount].to_f)
      expect(current_user.wallet.reload.balance).to eq(amount - params[:amount].to_f)
    end
  end
end
