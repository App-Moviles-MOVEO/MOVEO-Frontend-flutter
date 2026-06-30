import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:wheelspe_provider/features/transactions/data/transaction_model.dart';

/// Genera comprobantes/contratos en PDF **en el dispositivo** (US25).
///
/// El backend no tiene `/invoices`; el comprobante se construye con los datos
/// del cobro y se abre el diálogo de impresión/compartir del sistema.
class ReceiptService {
  const ReceiptService();

  Future<void> shareReceipt(TransactionModel tx, {String? providerName}) async {
    final money = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(28),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('WheelsPe',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text('COMPROBANTE',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text('N° WPE-${tx.id}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Divider(),
              pw.SizedBox(height: 8),
              _line('Fecha', df.format(tx.date)),
              if (providerName != null) _line('Proveedor', providerName),
              if (tx.payerName.isNotEmpty) _line('Cliente', tx.payerName),
              _line('Concepto',
                  tx.description.isEmpty ? 'Servicio WheelsPe' : tx.description),
              if (tx.reference.isNotEmpty) _line('Referencia', tx.reference),
              _line('Estado', tx.status.apiValue.toUpperCase()),
              pw.SizedBox(height: 16),
              pw.Divider(),
              _line('Monto total', money.format(tx.amount)),
              _line('Comisión plataforma', '- ${money.format(tx.platformFee)}'),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('NETO RECIBIDO',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(money.format(tx.netAmount),
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Spacer(),
              pw.Text(
                'Documento generado por la app WheelsPe. No es un comprobante '
                'electrónico autorizado por SUNAT.',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
              ),
            ],
          ),
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'comprobante-WPE-${tx.id}.pdf',
    );
  }

  pw.Widget _line(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey800)),
            pw.Text(value),
          ],
        ),
      );
}

final receiptServiceProvider =
    Provider<ReceiptService>((ref) => const ReceiptService());
