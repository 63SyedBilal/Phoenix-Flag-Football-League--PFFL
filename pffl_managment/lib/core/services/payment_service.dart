import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Service for payment-related API calls
class PaymentService {
  /// Get Dio instance with authentication token and working URL
  static Future<Dio> _getAuthenticatedDio() async {
    // Use AuthService's working Dio instance which has the correct URL
    return await AuthService.getWorkingDio();
  }

  /// Get all payments for superadmin
  /// GET /api/superadmin/payments/all?status=paid|unpaid|all
  static Future<List<Map<String, dynamic>>> getAllPayments(
    String status,
  ) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get(
        '/superadmin/payments/all',
        queryParameters: {'status': status},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        } else if (data['data'] != null) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        print('Failed to fetch payments: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('Error fetching payments: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return [];
    }
  }

  /// Get or create payment for logged-in user and specific league
  /// GET /api/payments/my?leagueId=xxx
  static Future<Map<String, dynamic>?> getOrCreatePayment(
    String leagueId,
  ) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get(
        '/payments/my',
        queryParameters: {'leagueId': leagueId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } on DioException catch (e) {
      print('Error getting/creating payment: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('General error getting/creating payment: $e');
      return null;
    }
  }

  /// Get unpaid payments for current user
  /// GET /api/payments/unpaid
  static Future<List<Map<String, dynamic>>> fetchUnpaidPayments() async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/payments/unpaid');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      }
      return [];
    } on DioException catch (e) {
      print('Error fetching unpaid payments: ${e.message}');
      return [];
    } catch (e) {
      print('General error fetching unpaid payments: $e');
      return [];
    }
  }

  /// Get all teams
  /// GET /api/team
  static Future<List<Map<String, dynamic>>> getAllTeams() async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/team');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        print('Failed to fetch teams: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('Error fetching teams: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print('General error fetching teams: $e');
      return [];
    }
  }

  /// Search users
  /// Get all payments for the current user
  /// GET /api/payments/my
  static Future<Map<String, dynamic>> fetchUserPayments() async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/payments/my');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'] ?? [],
            'message': data['message'] ?? 'Payments retrieved successfully',
          };
        }
        return {
          'success': false,
          'data': [],
          'message': data['message'] ?? 'Failed to fetch payments',
        };
      } else {
        return {
          'success': false,
          'data': [],
          'message': 'Failed to fetch user payments: ${response.statusMessage}',
        };
      }
    } on DioException catch (e) {
      print('Error fetching user payments: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        return {
          'success': false,
          'data': [],
          'message':
              e.response?.data?['error'] ?? 'Failed to fetch user payments',
        };
      }
      return {
        'success': false,
        'data': [],
        'message': 'Network error while fetching payments: ${e.message}',
      };
    } catch (e) {
      print('General error fetching user payments: $e');
      return {
        'success': false,
        'data': [],
        'message': 'An unexpected error occurred while fetching payments',
      };
    }
  }

  /// Get all payments for the captain's team
  /// GET /api/payments/team (admin endpoint for captains)
  static Future<Map<String, dynamic>> fetchTeamPayments() async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/payments/team');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'] ?? [],
            'message':
                data['message'] ?? 'Team payments retrieved successfully',
          };
        }
        return {
          'success': false,
          'data': [],
          'message': data['message'] ?? 'Failed to fetch team payments',
        };
      } else {
        return {
          'success': false,
          'data': [],
          'message': 'Failed to fetch team payments: ${response.statusMessage}',
        };
      }
    } on DioException catch (e) {
      print('Error fetching team payments: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        return {
          'success': false,
          'data': [],
          'message':
              e.response?.data?['error'] ?? 'Failed to fetch team payments',
        };
      }
      return {
        'success': false,
        'data': [],
        'message': 'Network error while fetching team payments: ${e.message}',
      };
    } catch (e) {
      print('General error fetching team payments: $e');
      return {
        'success': false,
        'data': [],
        'message': 'An unexpected error occurred while fetching team payments',
      };
    }
  }

  /// GET /api/user
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/user');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          final allUsers = (data['data'] as List).cast<Map<String, dynamic>>();
          // Filter users by query (search in name or email)
          if (query.isEmpty) {
            return allUsers;
          }
          final lowerQuery = query.toLowerCase();
          return allUsers.where((user) {
            final firstName = (user['firstName'] as String? ?? '')
                .toLowerCase();
            final lastName = (user['lastName'] as String? ?? '').toLowerCase();
            final email = (user['email'] as String? ?? '').toLowerCase();
            return firstName.contains(lowerQuery) ||
                lastName.contains(lowerQuery) ||
                email.contains(lowerQuery) ||
                '$firstName $lastName'.trim().contains(lowerQuery);
          }).toList();
        }
        return [];
      } else {
        print('Failed to search users: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('Error searching users: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print('General error searching users: $e');
      return [];
    }
  }

  /// Process payment (Stripe)
  /// POST /api/payments/process
  static Future<Map<String, dynamic>> processPayment({
    required String paymentId,
    required String paymentMethod,
    required Map<String, dynamic> cardDetails,
  }) async {
    try {
      final dio = await _getAuthenticatedDio();

      // Format data according to backend expectations
      final cardNumber =
          (cardDetails['cardNumber'] ??
                  cardDetails['number'] ??
                  cardDetails['card_number'])
              ?.toString()
              .replaceAll(' ', '');
      final expMonth = cardDetails['expMonth'] ?? cardDetails['exp_month'];
      final expYear = cardDetails['expYear'] ?? cardDetails['exp_year'];
      final cvc = cardDetails['cvv'] ?? cardDetails['cvc'];
      final name = (cardDetails['cardholderName'] ?? cardDetails['name'])
          ?.toString();
      final zip =
          (cardDetails['zipCode'] ??
                  cardDetails['zip_code'] ??
                  cardDetails['address_zip'])
              ?.toString();

      final data = {
        'paymentId': paymentId,
        'paymentMethod': paymentMethod,
        'payment_method': paymentMethod,
        'method': paymentMethod,
        'cardNumber': cardNumber,
        'expiryDate':
            cardDetails['exp_date'] ??
            cardDetails['expiryDate'] ??
            cardDetails['expiry'],
        'cvv': cvc,

        // Nested payload variants (some backends expect nested objects)
        'cardDetails': cardDetails,
        'card_details': cardDetails,
        'card': {
          if (cardNumber != null) 'number': cardNumber,
          if (expMonth != null) 'exp_month': expMonth,
          if (expYear != null) 'exp_year': expYear,
          if (cvc != null) 'cvc': cvc,
        },
        'billing_details': {
          if (name != null) 'name': name,
          if (zip != null) 'address': {'postal_code': zip},
        },

        ...cardDetails,
      };

      print('🚀 Request Payload: $data');
      print('💳 Sending payment request to /payments/process');
      print('   - Payment ID: $paymentId');
      print('   - Payment Method: $paymentMethod');
      print(
        '   - Card Number: **** **** **** ${data['cardNumber']?.toString().substring(data['cardNumber'].toString().length - 4)}',
      );

      // Send as JSON data with detailed error logging
      print(
        '📡 Making authenticated request to: ${dio.options.baseUrl}/payments/process',
      );
      print('🔐 Auth headers: ${dio.options.headers}');

      final response = await dio.post(
        '/payments/process',
        data: data,
        options: Options(validateStatus: (_) => true),
      );

      final body = response.data;
      final status = response.statusCode ?? 0;

      if (status == 200 || status == 201) {
        return {
          'success': true,
          'message': body is Map
              ? (body['message'] ?? 'Payment successful')
              : 'Payment successful',
          'data': body is Map ? body['data'] : body,
        };
      } else {
        return {
          'success': false,
          'message': body is Map
              ? (body['error'] ?? body['message'] ?? 'Payment failed')
              : (body?.toString() ?? 'Payment failed'),
          'errorType': body is Map ? body['errorType'] : null,
          'statusCode': status,
        };
      }

     
    } on DioException catch (e) {

      if (e.response != null) {

        // Check if it's a server error (5xx)
        if (e.response!.statusCode! >= 500) {
          
        }

        return {
          'success': false,
          'statusCode': e.response?.statusCode,
          'errorType': e.response?.data is Map
              ? e.response?.data['errorType']
              : null,
          'message': e.response?.data is Map
              ? (e.response?.data['error'] ??
                    e.response?.data['message'] ??
                    'Payment service error')
              : (e.response?.data?.toString() ?? 'Payment service error'),
        };
      }
      return {
        'success': false,
        'message': 'Failed to connect to payment service: ${e.message}',
      };
    } catch (e) {
      print('❌ General Payment Error: $e');
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  /// Get payment details by payment ID
  /// GET /api/payments/:paymentId
  static Future<Map<String, dynamic>?> getPaymentById(String paymentId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/payments/$paymentId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } on DioException catch (e) {
      print('Error fetching payment by ID: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('General error fetching payment by ID: $e');
      return null;
    }
  }
}
