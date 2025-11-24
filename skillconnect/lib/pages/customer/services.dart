import 'package:flutter/material.dart';
import 'package:skillconnect/pages/customer/ser_agents.dart';

class ServiceCategory {
  final String name;
  final String imageUrl;

  ServiceCategory(this.name, this.imageUrl);
}

class SelectService extends StatefulWidget {
  const SelectService({super.key});

  @override
  State<SelectService> createState() => _SelectServiceState();
}

class _SelectServiceState extends State<SelectService> {
  // --- UI Color Scheme ---
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);

  String? selectedService;

  final List<ServiceCategory> services = [
    ServiceCategory(
      'Electrical Work',
      'https://img.icons8.com/external-wanicon-flat-wanicon/2x/external-multimeter-car-service-wanicon-flat-wanicon.png',
    ),
    ServiceCategory(
      'Plumbing',
      'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-plumber-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png',
    ),
    ServiceCategory('Carpentry', 'https://img.icons8.com/fluency/2x/drill.png'),
    ServiceCategory(
      'AC Repair',
      'https://img.icons8.com/?size=100&id=Jskg4-JWkjF4&format=png&color=000000',
    ),
    ServiceCategory(
      'Washing Machine Repair',
      'https://img.icons8.com/?size=100&id=Jvd285hxXqK6&format=png&color=000000',
    ),
    ServiceCategory(
      'Refrigerator Repair',
      'https://img.icons8.com/?size=100&id=56605&format=png&color=000000',
    ),
    ServiceCategory(
      'RO Water Purifier Repair',
      'https://img.icons8.com/?size=100&id=WPAThkXXlAN9&format=png&color=000000',
    ),
    ServiceCategory(
      'Microwave Repair',
      'https://img.icons8.com/?size=100&id=66304&format=png&color=000000',
    ),
    ServiceCategory(
      'Geyser Repair',
      'https://img.icons8.com/?size=100&id=65540&format=png&color=000000',
    ),
    ServiceCategory(
      'Chimney & Hob Repair',
      'https://img.icons8.com/?size=100&id=zY1O74QugicA&format=png&color=000000',
    ),
    ServiceCategory(
      'Cleaning',
      'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-cleaning-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png',
    ),
    ServiceCategory(
      'Pest Control',
      'https://img.icons8.com/?size=100&id=0iDzTSlNteTH&format=png&color=000000',
    ),
    ServiceCategory(
      'Bathroom Cleaning',
      'https://img.icons8.com/external-flaticons-flat-flat-icons/2x/external-bathroom-cleaning-flaticons-flat-flat-icons.png',
    ),
    ServiceCategory(
      'Kitchen Cleaning',
      'https://img.icons8.com/external-flaticons-flat-flat-icons/2x/external-kitchen-cleaning-flaticons-flat-flat-icons.png',
    ),
    ServiceCategory(
      'Carpet Cleaning',
      'https://img.icons8.com/?size=100&id=s36AxpVEwPRt&format=png&color=000000',
    ),
    ServiceCategory(
      'Car Cleaning',
      'https://img.icons8.com/?size=100&id=tmJ81kcHHY3d&format=png&color=000000',
    ),
    ServiceCategory(
      'Painting',
      'https://img.icons8.com/external-itim2101-flat-itim2101/2x/external-painter-male-occupation-avatar-itim2101-flat-itim2101.png',
    ),
    ServiceCategory(
      'Moving Services',
      'https://img.icons8.com/?size=100&id=R6SgTreFdP9v&format=png&color=000000',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Service',
          style: TextStyle(
            color: darkBlue,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Which service\ndo you need?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: darkBlue,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  final isSelected = selectedService == service.name;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedService = service.name;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? lightBlue : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.network(
                              service.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.work,
                                  size: 40,
                                  color: lightBlue,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            service.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: darkBlue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (selectedService != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvailableAgentsPage(
                          selectedService: selectedService!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue with $selectedService',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
