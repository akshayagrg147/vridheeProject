import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:teaching_app/pages/clicker_registeration/controller/clicker_registration_controller.dart';
import 'package:teaching_app/widgets/edit_text.dart';

class AddClickers extends StatefulWidget {
  const AddClickers({super.key});

  @override
  State<AddClickers> createState() => _AddClickersState();
}

class _AddClickersState extends State<AddClickers> {
  final _clickerController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _clickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _clickerController.clear();
        showDialog(
            context: context,
            builder: (context) {
              return Center(
                  child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 300,
                  width: 350,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Text(
                          "Generate Clickers",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        EditText(
                          hint: "Enter No of Clickers Need to add",
                          labelText: "Clickers Count",
                          controller: _clickerController,
                          inputType: TextInputType.number,
                          inputformats: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onValidate: (value) {
                            if (value!.isEmpty) {
                              return "Clickers Count is Mandatory to generate Clickers";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              Get.find<ClickerRegistrationController>()
                                  .generateClickers(
                                      int.parse(_clickerController.text));
                            }
                          },
                          child: const Text(
                            'Genrate', // The text to display
                            textAlign: TextAlign
                                .center, // Ensures text is centered within the button
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical:
                                    20), // Optional: adjust padding for button size
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
            });
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300)),
        padding: const EdgeInsets.all(12),
        alignment: Alignment.center,
        child: Icon(
          Icons.add_circle_outline_rounded,
          size: 70,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}
