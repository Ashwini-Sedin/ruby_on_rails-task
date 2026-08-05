class ReportCardService
  def self.generate(student)
    raise ArgumentError, "Student cannot be nil" if student.nil?

    grade = student.grade.to_s
    result = student.result.to_s

    Prawn::Document.new do |pdf|
      pdf.text "Report Card", size: 20, style: :bold
      pdf.move_down 10

      pdf.text "Name: #{student.name}"
      pdf.text "Course: #{student.course}"
      pdf.text "Marks: #{student.marks}"
      pdf.text "Grade: #{grade}"
      pdf.text "Result: #{result}"
    end.render
  end
end
