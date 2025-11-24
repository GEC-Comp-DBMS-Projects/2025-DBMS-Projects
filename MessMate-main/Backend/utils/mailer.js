const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// ✅ 1️⃣ OTP Email
const sendOtpEmail = async (to, otp) => {
  try {
    const mailOptions = {
      from: `"MessMate" <${process.env.EMAIL_USER}>`,
      to,
      subject: "MessMate OTP Verification",
      html: `
      <div style="font-family: Arial, sans-serif; background-color: #fffaf5; padding: 20px;">
        <div style="max-width: 600px; margin: auto; background: white; border-radius: 12px; padding: 30px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
          
          <!-- Logo -->
          <div style="text-align: center; margin-bottom: 20px;">
            <img src="${process.env.CLOUDINARY_LOGO_URL}" alt="MessMate Logo" width="70" style="margin-bottom: 10px;" />
            <h2 style="margin: 0; color: #FF4500;">MessMate</h2>
          </div>

          <h3 style="color: #333; text-align: center; margin-bottom: 10px;">Verify Your Identity</h3>
          <p style="text-align: center; color: #555; margin-bottom: 25px;">
            Use the OTP code below to continue with your verification.
          </p>

          <div style="text-align: center; margin-bottom: 20px;">
            <p style="font-size: 22px; font-weight: bold; background: linear-gradient(90deg, #FF7E5F, #FF4500); color: white; display: inline-block; padding: 12px 25px; border-radius: 8px; letter-spacing: 3px;">
              ${otp}
            </p>
          </div>

          <p style="color: #555; text-align: center; font-size: 14px;">
            This code is valid for <b>5 minutes</b> and can only be used once.<br>
            Please don’t share this code with anyone.
          </p>

          <div style="margin-top: 30px; text-align: center; font-size: 12px; color: gray;">
            <p>If you did not request this, you can safely ignore this email.</p>
            <p>© ${new Date().getFullYear()} MessMate - Hostel Mess Management System</p>
          </div>
        </div>
      </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log(`✅ OTP email sent to ${to}`);
  } catch (error) {
    console.error("❌ Error sending email:", error);
    throw error;
  }
};

// ✅ 2️⃣ Admin Invite Email
const sendInviteEmail = async (to, full_name, email, password) => {
  const html = `
    <div style="font-family: Arial, sans-serif; background-color: #fffaf5; padding: 20px;">
      <div style="max-width: 600px; margin: auto; background: white; border-radius: 12px; padding: 30px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
        <div style="text-align: center; margin-bottom: 20px;">
          <img src="${process.env.CLOUDINARY_LOGO_URL}" alt="MessMate Logo" width="70" style="margin-bottom: 10px;" />
          <h2 style="margin: 0; color: #FF4500;">MessMate</h2>
        </div>
        <h3 style="color: #333; text-align: center;">You’ve been invited to MessMate!</h3>
        <p style="text-align: center; color: #555;">Hi ${full_name},</p>
        <p style="text-align: center; color: #555;">Here are your login credentials:</p>
        <div style="text-align: center; background-color: #f9f9f9; padding: 15px; border-radius: 8px; margin: 10px auto; width: fit-content;">
          <p><b>Email:</b> ${email}</p>
          <p><b>Password:</b> ${password}</p>
        </div>
        <p style="text-align: center; color: #555;">Please change your password after logging in.</p>
        <div style="margin-top: 30px; text-align: center; font-size: 12px; color: gray;">
          <p>© ${new Date().getFullYear()} MessMate - Hostel Mess Management System</p>
        </div>
      </div>
    </div>
  `;

  try {
    await transporter.sendMail({
      from: `"MessMate" <${process.env.EMAIL_USER}>`,
      to,
      subject: "Your MessMate Login Credentials",
      html,
    });
    console.log(`✅ Invite email sent to ${to}`);
  } catch (error) {
    console.error("❌ Error sending invite email:", error);
    throw error;
  }
};

// ✅ 3️⃣ Send meal attendance
const sendMealAttendanceEmail = async (to, meal, count) => {
  try {
    const html = `
      <div style="font-family: Arial, sans-serif; background-color: #fffaf5; padding: 20px;">
        <div style="max-width: 600px; margin: auto; background: white; border-radius: 12px; padding: 30px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
          <div style="text-align: center; margin-bottom: 20px;">
            <img src="${process.env.CLOUDINARY_LOGO_URL}" alt="MessMate Logo" width="70" style="margin-bottom: 10px;" />
            <h2 style="margin: 0; color: #FF4500;">MessMate</h2>
          </div>
          <h3 style="color: #333; text-align: center; margin-bottom: 10px;">
            Today's ${meal.toUpperCase()} Attendance
          </h3>
          <div style="text-align: center; background-color: #f9f9f9; padding: 20px; border-radius: 10px; margin: 20px auto; width: fit-content;">
            <p style="font-size: 20px; font-weight: bold; color: #FF4500; margin: 0;">
              Total Students: ${count}
            </p>
          </div>
          <div style="margin-top: 30px; text-align: center; font-size: 12px; color: gray;">
            <p>© ${new Date().getFullYear()} MessMate - Hostel Mess Management System</p>
          </div>
        </div>
      </div>
    `;

    await transporter.sendMail({
      from: `"MessMate" <${process.env.EMAIL_USER}>`,
      to,
      subject: `Attendance for ${meal.toUpperCase()} - Today`,
      html,
    });

    console.log(`✅ Meal attendance email sent to ${to}`);
  } catch (error) {
    console.error(`❌ Error sending ${meal} email:`, error);
  }
};

module.exports = { sendInviteEmail, sendOtpEmail, sendMealAttendanceEmail };





