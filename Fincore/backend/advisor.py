When financial data is provided in context, analyze it professionally and provide insights based on spending patterns, income trends, and account balances."""

def get_db_connection():
    """Create and return a database connection"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except Error as e:
        print(f"❌ Database connection error: {e}")
        return None

def init_advisor_tables():
    """Initialize advisor-specific database tables"""
    connection = get_db_connection()
    if not connection:
        print("❌ Cannot initialize advisor tables - no database connection")
        return False
    
    cursor = connection.cursor()
    
    try:
        ''')
        
    """
    financial_keywords = [
        'spending', 'spent', 'expense', 'expenses', 'transaction', 'transactions',
        'balance', 'account', 'money', 'budget', 'save', 'saving', 'savings',
        'income', 'earn', 'earning', 'salary', 'credit', 'debit',
        
        'last month', 'this month', 'last week', 'this week', 'recent',
        
        'my finances', 'my accounts', 'my data', 'my bank', 'my spending',
        'my transactions', 'my money', 'my balance', 'my savings', 'my income',
        
        'analyze', 'analysis', 'insight', 'pattern', 'trend', 'review',
        'how much', 'where did', 'what did', 'show me', 'tell me about',
        
        'financial health', 'financial condition', 'financial status',
        'financial situation', 'doing financially', 'am i doing',
        'how am i', 'how is my', 'is my', 'are my',
        
        'good', 'bad', 'healthy', 'unhealthy', 'okay', 'fine',
        'concern', 'worried', 'safe', 'secure', 'stable',
        
        'should i', 'can i afford', 'recommend', 'suggestion', 'advice',
        'what to do', 'help me'
    ]
    
    query_lower = keywords_in_query.lower()
    needs_financial_data = any(keyword in query_lower for keyword in financial_keywords)
    
    if not needs_financial_data:
        print(f"⏭️ No financial keywords detected in: '{keywords_in_query[:50]}...'")
        return None, False
    
    print(f"📊 Financial context will be included for query: '{keywords_in_query[:50]}...'")
    
    connection = get_db_connection()
    if not connection:
        return None, False
    
    cursor = connection.cursor(dictionary=True)
    context = {}
    
    try:
        ''', (user_id,))
        txn_summary = cursor.fetchone()
        
        if txn_summary and txn_summary['total_transactions'] > 0:
            context['monthly_summary'] = {
                'period': 'last_30_days',
                'total_transactions': txn_summary['total_transactions'],
                'total_income': float(txn_summary['total_income'] or 0),
                'total_expenses': float(txn_summary['total_expenses'] or 0),
                'net_savings': float((txn_summary['total_income'] or 0) - (txn_summary['total_expenses'] or 0)),
                'income_count': txn_summary['income_count'],
                'expense_count': txn_summary['expense_count']
            }
            
            if txn_summary['total_income'] and txn_summary['total_income'] > 0:
                context['monthly_summary']['savings_rate'] = round(
                    (context['monthly_summary']['net_savings'] / float(txn_summary['total_income'])) * 100, 2
                )
        
        ''', (user_id,))
        large_txns = cursor.fetchall()
        
        if large_txns:
            context['recent_large_transactions'] = [
                {
                    'type': txn['transaction_type'],
                    'category': txn['mode'] or 'OTHER',
                    'amount': float(txn['amount']),
                    'date': txn['transaction_date'].strftime('%Y-%m-%d') if txn['transaction_date'] else None
                }
                for txn in large_txns
            ]
        
        return context if context else None, True
        
    except Error as e:
        print(f"❌ Error extracting financial context: {e}")
        return None, False
    finally:
        cursor.close()
        connection.close()

def generate_context_prompt(financial_context):
    """Generate a prompt section with financial context"""
    if not financial_context:
        return ""
    
    prompt = "\n\n**USER'S FINANCIAL CONTEXT (Anonymized):**\n"
    
    if 'accounts' in financial_context:
        acc = financial_context['accounts']
        prompt += f"- Has {acc['total_accounts']} bank account(s)\n"
        prompt += f"- Total balance: ₹{acc['total_balance']:,.2f}\n"
    
    if 'monthly_summary' in financial_context:
        ms = financial_context['monthly_summary']
        prompt += f"\n**Last 30 Days Summary:**\n"
        prompt += f"- Total income: ₹{ms['total_income']:,.2f} ({ms['income_count']} transactions)\n"
        prompt += f"- Total expenses: ₹{ms['total_expenses']:,.2f} ({ms['expense_count']} transactions)\n"
        prompt += f"- Net savings: ₹{ms['net_savings']:,.2f}\n"
        if 'savings_rate' in ms:
            prompt += f"- Savings rate: {ms['savings_rate']}%\n"
    
    if 'spending_breakdown' in financial_context:
        prompt += f"\n**Top Spending Categories:**\n"
        for cat in financial_context['spending_breakdown'][:5]:
            prompt += f"- {cat['category']}: ₹{cat['total']:,.2f} ({cat['count']} transactions)\n"
    
    if 'recent_large_transactions' in financial_context:
        prompt += f"\n**Recent Large Transactions (Last 7 days):**\n"
        for txn in financial_context['recent_large_transactions'][:3]:
            prompt += f"- {txn['type']}: ₹{txn['amount']:,.2f} ({txn['category']})\n"
    
    prompt += "\nUse this data to provide personalized insights. DO NOT reveal account numbers or personal identifiers.\n"
    
    return prompt

def get_chat_history(chat_id, limit=10):
    """Get recent chat history for context"""
    connection = get_db_connection()
    if not connection:
        return []
    
    cursor = connection.cursor(dictionary=True)
    try:
Respond with ONLY the title, no quotes or extra text. Make it relevant to the financial topic discussed."""
        
        response = model.generate_content(
            prompt,
            generation_config=genai.types.GenerationConfig(
                temperature=0.5,
                max_output_tokens=20,
            )
        )
        
        title = response.text.strip().replace('"', '').replace("'", "")
        
        if len(title) > 60 or len(title) < 3:
            return first_message[:50] + "..." if len(first_message) > 50 else first_message
        
        return title
        
    except Exception as e:
        print(f"❌ Title generation error: {e}")
        return first_message[:50] + "..." if len(first_message) > 50 else first_message

def format_ai_response(text):
    """Format AI response text for better readability in mobile app"""
    if not text:
        return text
    
    formatted = text
    
    import re
    formatted = re.sub(r'\*\*([^*]+)\*\*', r'• \1', formatted)
    formatted = re.sub(r'__([^_]+)__', r'• \1', formatted)
    
    formatted = re.sub(r'^\s*[\*\-\+]\s+', '• ', formatted, flags=re.MULTILINE)
    
    formatted = re.sub(r'^\s*(\d+)\.\s+', r'[\1] ', formatted, flags=re.MULTILINE)
    
    formatted = re.sub(r'\n{3,}', '\n\n', formatted)
    
    formatted = formatted.strip()
    
    return formatted

@app.route('/advisor/chats/list', methods=['POST'])
def list_chats():
    """Get all chats for a user"""
    try:
        data = request.json
        email = data.get('email')
        
        if not email:
            return jsonify({'success': False, 'error': 'Email is required'}), 400
        
        user_id = get_user_id_from_email(email)
        if not user_id:
            return jsonify({'success': False, 'error': 'User not found'}), 404
        
        connection = get_db_connection()
        if not connection:
            return jsonify({'success': False, 'error': 'Database connection failed'}), 500
        
        cursor = connection.cursor(dictionary=True)
        ''', (user_id, chat_id, title, 'Start a new conversation...'))
        
        connection.commit()
        cursor.close()
        connection.close()
        
        return jsonify({
            'success': True,
            'chat': {
                'id': chat_id,
                'title': title,
                'preview': 'Start a new conversation...',
                'created_at': datetime.now().isoformat()
            }
        })
        
    except Exception as e:
        print(f"❌ Error creating chat: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/advisor/chats/delete', methods=['POST'])
def delete_chat():
    """Delete a chat (soft delete)"""
    try:
        data = request.json
        email = data.get('email')
        chat_id = data.get('chatId')
        
        if not email or not chat_id:
            return jsonify({'success': False, 'error': 'Email and chatId are required'}), 400
        
        user_id = get_user_id_from_email(email)
        if not user_id:
            return jsonify({'success': False, 'error': 'User not found'}), 404
        
        connection = get_db_connection()
        if not connection:
            return jsonify({'success': False, 'error': 'Database connection failed'}), 500
        
        cursor = connection.cursor()
        ''', (chat_id,))
        
        messages = cursor.fetchall()
        
        for msg in messages:
            if msg['created_at']:
                msg['created_at'] = msg['created_at'].isoformat()
            if msg['type'] == 'assistant':
                msg['type'] = 'advisor'
        
        cursor.close()
        connection.close()
        
        return jsonify({
            'success': True,
            'messages': messages,
            'count': len(messages)
        })
        
    except Exception as e:
        print(f"❌ Error listing messages: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/advisor/messages/send', methods=['POST'])
def send_message():
    """Send a message and get AI response"""
    try:
        data = request.json
        email = data.get('email')
        chat_id = data.get('chatId')
        message = data.get('message')
        
        if not email or not chat_id or not message:
            return jsonify({'success': False, 'error': 'email, chatId, and message are required'}), 400
        
        user_id = get_user_id_from_email(email)
        if not user_id:
            return jsonify({'success': False, 'error': 'User not found'}), 404
        
        connection = get_db_connection()
        if not connection:
            return jsonify({'success': False, 'error': 'Database connection failed'}), 500
        
        cursor = connection.cursor(dictionary=True)
        ''', (chat_id, user_message_id, message))
        connection.commit()
        
        chat_history = get_chat_history(chat_id, limit=10)
        
        financial_context, context_used = extract_financial_context(user_id, message)
        
        ai_response = generate_ai_response(message, chat_history, financial_context)
        
        ai_response_formatted = format_ai_response(ai_response)
        
        ai_message_id = f"msg_{int(datetime.now().timestamp() * 1000)}_advisor"
            ''', (chat_title, message[:200], chat_id))
        else: