""", (account_id,))
        
        account = cursor.fetchone()
        
        cursor.close()
        connection.close()
        
        return account
    except Exception as e:
        print(f"❌ Error getting account info: {e}")
        return None

def get_account_financial_data(account_id):
        """, (account_id,))
        account = cursor.fetchone()
        
        if not account:
            cursor.close()
            connection.close()
            return None
        
        ninety_days_ago = (datetime.now() - timedelta(days=90)).strftime('%Y-%m-%d')
        
        """, (account_id, ninety_days_ago))
        spending_by_mode = cursor.fetchall()
        
        six_months_ago = (datetime.now() - timedelta(days=180)).strftime('%Y-%m-%d')
        
        """, (account_id, ninety_days_ago))
        all_daily_balances = cursor.fetchall()
        
        balance_history = []
        if all_daily_balances:
            balance_history = all_daily_balances
        
        """, (account_id, ninety_days_ago))
        recent_transactions = cursor.fetchall()
        
        cursor.close()
        connection.close()
        
        account_balance = float(account['current_balance'])
        
        total_income = float(transaction_summary['total_income'] or 0)
        total_expenses = float(transaction_summary['total_expenses'] or 0)
        net_savings = total_income - total_expenses
        savings_rate = (net_savings / total_income * 100) if total_income > 0 else 0
        
        return {
            'account': account,
            'account_balance': account_balance,
            'transaction_summary': transaction_summary,
            'spending_by_mode': spending_by_mode,
            'monthly_trend': monthly_trend,
            'balance_history': balance_history,
            'large_transactions': large_transactions,
            'recent_transactions': recent_transactions,
            'savings_rate': savings_rate,
            'net_savings': net_savings
        }
        
    except Exception as e:
        print(f"❌ Error getting financial data: {e}")
        import traceback
        traceback.print_exc()
        return None

def create_data_hash(financial_data):
    """
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        
    """
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        
    """
    if not model:
        return {
            'title': 'Financial Overview',
            'summary': 'AI analysis unavailable - API key not configured',
            'ai_analysis': 'Please configure GEMINI_API_KEY to enable AI insights.',
            'recommendations': []
        }
    
    try:
        account_info = financial_data['account']
        
        avg_monthly_income = float(financial_data['transaction_summary']['total_income'] or 0) / 3
        avg_monthly_expenses = float(financial_data['transaction_summary']['total_expenses'] or 0) / 3
        
        income = float(financial_data['transaction_summary']['total_income'] or 0)
        expenses = float(financial_data['transaction_summary']['total_expenses'] or 0)
        total_txns = financial_data['transaction_summary']['total_transactions']
        
        spending_by_mode = financial_data['spending_by_mode'][:10]
        total_spending = sum(float(m['total_amount']) for m in spending_by_mode)
        
        daily_avg_spending = expenses / 90 if expenses > 0 else 0
        txn_avg_amount = expenses / total_txns if total_txns > 0 else 0
        
        balance_to_monthly_expense_ratio = financial_data['account_balance'] / (avg_monthly_expenses or 1)
        income_volatility = "stable" if len(financial_data['monthly_trend']) < 2 else "variable"
        
"""
        
        recent_transactions = financial_data.get('recent_transactions', [])
        transaction_summary = ""
        if recent_transactions:
            transaction_summary = "\n\nRECENT TRANSACTIONS (Last 15):\n"
            for i, txn in enumerate(recent_transactions[:15], 1):
                transaction_summary += f"{i}. {txn.get('date', 'N/A')}: {txn.get('type', 'N/A')} ₹{txn.get('amount', 0):,.2f} - {txn.get('description', 'N/A')[:50]} ({txn.get('category', 'N/A')})\n"
        
        monthly_trend = ""
        if financial_data.get('monthly_trend'):
            monthly_trend = "\n\nMONTHLY TREND (Last 6 months):\n"
            for month in financial_data['monthly_trend']:
                m_income = float(month.get('income', 0))
                m_expenses = float(month.get('expenses', 0))
                net = m_income - m_expenses
                rate = (net / m_income * 100) if m_income > 0 else 0
                monthly_trend += f"- {month.get('month', 'N/A')}: Income ₹{m_income:,.0f}, Expenses ₹{m_expenses:,.0f}, Saved ₹{net:,.0f} ({rate:.1f}%)\n"
        
        """, (
            account_id,
            insight_id,
            insight_data['title'],
            insight_data['summary'],
            insight_data['ai_analysis'],
            json.dumps(insight_data['recommendations']),
            json.dumps(financial_data, default=decimal_to_float)
        ))
        
    """
    try:
        data = request.get_json()
        account_id = data.get('account_id')
        
        if not account_id:
            return jsonify({'success': False, 'error': 'Account ID is required'}), 400
        
        account_info = get_account_info(account_id)
        if not account_info:
            return jsonify({'success': False, 'error': 'Account not found'}), 404
        
        print(f"\n{'='*60}")
        print(f"📊 Generating insight for account: {account_info['masked_account_number']} ({account_info['fip_id']})")
        print(f"{'='*60}")
        
        financial_data = get_account_financial_data(account_id)
        if not financial_data:
            return jsonify({'success': False, 'error': 'No financial data available for this account'}), 404
        
        data_hash = create_data_hash(financial_data)
        
        if not needs_new_insight(account_id, data_hash):
            connection = get_db_connection()
            cursor = connection.cursor(dictionary=True)
            
        """, (account_id,))
        
        insights = cursor.fetchall()
        
        cursor.close()
        connection.close()
        
        for insight in insights:
            try:
                insight['recommendations'] = json.loads(insight['recommendations'])
            except:
                insight['recommendations'] = []
            
            if insight['created_at']:
                insight['created_at'] = insight['created_at'].isoformat()
        
        return jsonify({
            'success': True,
            'insights': insights,
            'count': len(insights)
        })
        
    except Exception as e:
        print(f"❌ Error in list_insights: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/insights/latest', methods=['POST'])
def get_latest_insight():
    """Get the most recent insight for a specific bank account"""
    try:
        data = request.get_json()
        account_id = data.get('account_id')
        
        if not account_id:
            return jsonify({'success': False, 'error': 'Account ID is required'}), 400
        
        account_info = get_account_info(account_id)
        if not account_info:
            return jsonify({'success': False, 'error': 'Account not found'}), 404
        
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)