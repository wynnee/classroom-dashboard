class StudentsController < ApplicationController
    def index
        @user = User.find(params[:user_id])
        proper_user(@user)
        @course = @user.courses.find(params[:course_id])
        @students = @course.students
    end

    def new
        @user = User.find(params[:user_id])
        proper_user(@user)
        @course = @user.courses.find(params[:course_id])
        @student = @course.students.new
    end

    def create
        @user = User.find(params[:user_id])
        proper_user(@user)
        @course = @user.courses.find(params[:course_id])
        @student = @course.students.create(student_params)
        if @student.save
            redirect_to user_course_student_path(@user, @course, @student)
        else
            render 'new'
      end
    end

    def show
        @user = User.find(params[:user_id])
        proper_user(@user)
        @course = @user.courses.find(params[:course_id])
        @student = @course.students.find(params[:id])
    end

    def destroy
        @user = User.find(params[:user_id])
        proper_user(@user)
        @course = @user.courses.find(params[:course_id])
        @student = @course.students.find(params[:id])
        @student.destroy
        redirect_to user_course_path(@user, @course)
    end

    def edit
        @user = User.find(params[:user_id])
        proper_user(@user)
        @course = @user.courses.find(params[:course_id])
        @student = @course.students.find(params[:id])
    end

    def update
        @user = User.find(params[:user_id])
        proper_user(@user)
        @course = @user.courses.find(params[:course_id])
        @student = @course.students.find(params[:id])

        if @student.update(student_params)
            redirect_to user_course_path(@user, @course)
        else
            render 'edit'
        end
    end

    # handles batch upload for students
    # The name of the file (minus the file extension, hopefully) will be the name of the student
    def import
        @user = User.find(params[:user_id])
        proper_user(@user)
        @course = @user.courses.find(params[:course_id])
        # Create a new student
        student = Student.new
        student.course_id = @course.id
        student.portrait = params[:file]
        # The name of the student is the name of the image
        student.name = student.portrait_file_name
        # Check that an image was actually grabbed my ensuring name is not empty or nil
        if student.name != "" and student.name != nil
            # Replace all underscores with spaces, as file names convert spaces to underscores
            if student.name.include? '_'
                student.name.gsub!('_', ' ')
            end
            # Get rid of the file extension. There is likely a better, more general way to do this,
            # but for simple applications this brute force way works
            if student.name.include? ".pdf" or student.name.include? ".jpg" or student.name.include? ".png" or student.name.include? ".JPG"
                student.name = student.name[0..-5]
            end
            student.save
        end

        redirect_to user_course_path(@user, @course)
    end

    private
        def student_params
            params.require(:student).permit(:name, :email, :portrait, :notes)
        end
end
