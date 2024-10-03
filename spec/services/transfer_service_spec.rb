# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransferService do
  let(:subject) { described_class.new }
  let(:sender) { create(:user) }
  let(:receiver) { create(:user) }
  let(:params) {
    {
      type: 'transfer',
      amount: 2000,
      source_wallet_id: sender.wallet.id,
      target_wallet_id: receiver.wallet.id
    }
  }

  context 'errors' do
    context 'when amount sender not meet' do
      it 'should raise error' do
        expect { subject.execute(sender, params) }.to raise_error(ApiExceptions::BadRequestError) do |error|
          expect(error.message).to eq("Invalid Data")
          expect(error.detail).to eq("Insufficient funds")
        end
      end
    end

    context 'when sender send to themself' do
      let(:params) {
        {
          type: 'transfer',
          amount: 2000,
          source_wallet_id: sender.wallet.id,
          target_wallet_id: sender.wallet.id
        }
      }

      it 'should raise error' do
        expect { subject.execute(sender, params) }.to raise_error(ApiExceptions::BadRequestError) do |error|
          expect(error.message).to eq("Invalid Data")
          expect(error.detail).to eq("Couldn't transfer to same wallet")
        end
      end
    end

    context 'when target or source wallet blank' do
      let(:params) {
        {
          type: 'transfer',
          amount: 2000,
        }
      }

      it 'should raise error' do
        expect { subject.execute(sender, params) }.to raise_error(ApiExceptions::BadRequestError) do |error|
          expect(error.message).to eq("Invalid Data")
          expect(error.detail).to eq("Target or Source wallet cannot be blank")
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
            target_wallet_id: sender.wallet.id
          }
        }

        it 'should raise error' do
          expect { subject.execute(sender, params) }.to raise_error(ApiExceptions::BadRequestError) do |error|
            expect(error.message).to eq("Invalid Data")
            expect(error.detail).to eq("User dont have access to this wallet")
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
          expect { subject.execute(sender, params) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'target wallet not found' do
        let(:id_wallet_not_found) { 9999 }
        let(:params) {
          {
            type: 'transfer',
            amount: 2000,
            source_wallet_id: sender.wallet.id,
            target_wallet_id: id_wallet_not_found
          }
        }
        it 'should raise error' do
          expect { subject.execute(sender, params) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  context 'success' do
    let(:amount) { 2000 }
    let(:params) {
      {
        type: 'transfer',
        amount: amount,
        source_wallet_id: sender.wallet.id,
        target_wallet_id: receiver.wallet.id
      }
    }

    before do
      sender.wallet.update_columns(balance: amount)
      create(:transaction, source_wallet: sender.wallet, amount: amount, type: Debit)
    end

    it 'should balance updated' do
      subject.execute(sender, params)
      total_amount = Transaction.where(source_wallet_id: receiver.wallet.id).sum(:amount)
      total_amount_sender = Transaction.where(source_wallet_id: sender.wallet.id).sum(:amount)

      expect(total_amount).to eq(amount)
      expect(total_amount_sender).to eq(amount - params[:amount])
    end
  end
end
