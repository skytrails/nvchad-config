<!-- 修改密码弹窗 - 优化版 -->
<template>
  <el-dialog width="460px" :title="null" :visible="visible" :lock-scroll="false" :append-to-body="true"
    :show-close="false" :close-on-click-modal="false" :close-on-press-escape="false"
    custom-class="password-update-dialog" @update:visible="updateVisible" @closed="onClose">
    <!-- 自定义头部 -->
    <div class="dialog-header">
      <div class="header-icon">
        <i class="el-icon-lock"></i>
      </div>
      <div class="header-content">
        <h3>修改密码</h3>
        <p>为了您的账户安全，请定期修改密码</p>
      </div>
    </div>

    <div class="dialog-body">
      <!-- 密码强度指示器 -->
      <div class="password-strength" v-if="form.newPassword">
        <div class="strength-label">密码强度:</div>
        <div class="strength-bars">
          <div v-for="level in 4" :key="level" class="strength-bar" :class="{
            'active': passwordLevel >= level,
            'level-1': passwordLevel === 1,
            'level-2': passwordLevel === 2,
            'level-3': passwordLevel === 3,
            'level-4': passwordLevel === 4
          }"></div>
        </div>
        <div class="strength-text">{{ strengthText }}</div>
      </div>

      <el-form ref="form" :model="form" :rules="rules" label-width="0" size="medium" @keyup.enter.native="save">
        <!-- 旧密码 -->
        <div class="form-item-group">
          <div class="item-label">
            <i class="el-icon-key"></i>
            <span>旧密码</span>
          </div>
          <el-form-item prop="oldPassword">
            <el-input v-model="form.oldPassword" type="password" placeholder="请输入当前使用的密码" show-password clearable
              :prefix-icon="null" class="password-input" @focus="handleInputFocus('oldPassword')">
              <template #prefix>
                <i class="el-icon-lock prefix-icon"></i>
              </template>
            </el-input>
          </el-form-item>
        </div>

        <!-- 新密码 -->
        <div class="form-item-group">
          <div class="item-label">
            <i class="el-icon-key"></i>
            <span>新密码</span>
            <span class="hint-text">（8-20位，包含字母和数字）</span>
          </div>
          <el-form-item prop="newPassword">
            <el-input v-model="form.newPassword" type="password" placeholder="请输入新密码" show-password clearable
              class="password-input" @input="checkPasswordStrength" @focus="handleInputFocus('newPassword')">
              <template #prefix>
                <i class="el-icon-refresh prefix-icon"></i>
              </template>
            </el-input>
          </el-form-item>
          <div class="password-hints" v-if="form.newPassword">
            <div class="hint-item" :class="{ 'valid': hasUpperCase }">
              <i class="el-icon-check"></i> 包含大写字母
            </div>
            <div class="hint-item" :class="{ 'valid': hasLowerCase }">
              <i class="el-icon-check"></i> 包含小写字母
            </div>
            <div class="hint-item" :class="{ 'valid': hasNumber }">
              <i class="el-icon-check"></i> 包含数字
            </div>
            <div class="hint-item" :class="{ 'valid': hasSpecialChar }">
              <i class="el-icon-check"></i> 包含特殊字符
            </div>
            <div class="hint-item" :class="{ 'valid': form.newPassword.length >= 8 }">
              <i class="el-icon-check"></i> 长度至少8位
            </div>
          </div>
        </div>

        <!-- 确认密码 -->
        <div class="form-item-group">
          <div class="item-label">
            <i class="el-icon-key"></i>
            <span>确认密码</span>
          </div>
          <el-form-item prop="confirmPassword">
            <el-input v-model="form.confirmPassword" type="password" placeholder="请再次输入新密码" show-password clearable
              class="password-input" @focus="handleInputFocus('confirmPassword')">
              <template #prefix>
                <i class="el-icon-check prefix-icon"></i>
              </template>
            </el-input>
          </el-form-item>
          <div class="password-match" v-if="form.confirmPassword">
            <i class="el-icon-success" v-if="passwordMatch"></i>
            <i class="el-icon-error" v-else></i>
            <span>{{ passwordMatch ? '密码匹配成功' : '两次输入的密码不一致' }}</span>
          </div>
        </div>
      </el-form>
    </div>

    <div class="dialog-footer">
      <div class="footer-tips">
        <i class="el-icon-warning-outline"></i>
        <span>修改密码后需要重新登录</span>
      </div>
      <div class="footer-buttons">
        <el-button size="medium" @click="cancel" class="cancel-btn">
          取消
        </el-button>
        <el-button type="primary" size="medium" @click="save" :loading="loading" :disabled="!isFormValid"
          class="confirm-btn">
          {{ loading ? '修改中...' : '确认修改' }}
        </el-button>
      </div>
    </div>
  </el-dialog>
</template>

<script>
export default {
  name: "UpdatePwd",
  props: {
    visible: Boolean,
  },
  data() {
    const validateNewPassword = (rule, value, callback) => {
      if (!value) {
        callback(new Error("请输入新密码"));
      } else if (value.length < 8 || value.length > 20) {
        callback(new Error("密码长度需在8-20位之间"));
      } else if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(value)) {
        callback(new Error("密码需包含大小写字母和数字"));
      } else {
        callback();
      }
    };

    const validateConfirmPassword = (rule, value, callback) => {
      if (!value) {
        callback(new Error("请再次输入密码"));
      } else if (value !== this.form.newPassword) {
        callback(new Error("两次输入的密码不一致"));
      } else {
        callback();
      }
    };

    return {
      form: {
        oldPassword: "",
        newPassword: "",
        confirmPassword: "",
      },
      rules: {
        oldPassword: [
          { required: true, message: "请输入旧密码", trigger: "blur" }
        ],
        newPassword: [
          { required: true, validator: validateNewPassword, trigger: "blur" }
        ],
        confirmPassword: [
          { required: true, validator: validateConfirmPassword, trigger: "blur" }
        ],
      },
      loading: false,
      // 密码强度相关
      passwordLevel: 0,
      hasUpperCase: false,
      hasLowerCase: false,
      hasNumber: false,
      hasSpecialChar: false,
    };
  },
  computed: {
    strengthText() {
      const texts = ["弱", "一般", "较强", "强"];
      return this.passwordLevel > 0 ? texts[this.passwordLevel - 1] : "请设置密码";
    },
    passwordMatch() {
      return this.form.confirmPassword && this.form.newPassword === this.form.confirmPassword;
    },
    isFormValid() {
      return this.form.oldPassword &&
        this.form.newPassword &&
        this.form.confirmPassword &&
        this.passwordMatch &&
        this.passwordLevel >= 2;
    }
  },
  methods: {
    checkPasswordStrength() {
      const password = this.form.newPassword;

      // 检查字符类型
      this.hasUpperCase = /[A-Z]/.test(password);
      this.hasLowerCase = /[a-z]/.test(password);
      this.hasNumber = /\d/.test(password);
      this.hasSpecialChar = /[!@#$%^&*()_+\-=[]{};':"\|,.<>\/?]/.test(password);

      // 计算密码强度等级
      let score = 0;
      if (password.length >= 8) score++;
      if (this.hasUpperCase && this.hasLowerCase) score++;
      if (this.hasNumber) score++;
      if (this.hasSpecialChar) score++;
      if (password.length >= 12) score++;

      this.passwordLevel = Math.min(score, 4);
    },

    handleInputFocus(field) {
      // 可以添加一些焦点效果，比如高亮边框等
      console.log(`Focus on ${field}`);
    },

    /* 保存修改 */
    save() {
      this.$refs["form"].validate((valid) => {
        if (valid && this.isFormValid) {
          this.loading = true;
          this.$http.post("/admin/updatePassword", {
            oldPassword: this.form.oldPassword,
            newPassword: this.form.newPassword
          })
            .then((res) => {
              this.loading = false;
              if (res.data.code === 200) {
                this.$message.success({
                  message: '密码修改成功！请重新登录',
                  duration: 3000,
                  showClose: true
                });
                this.cancel();
                // 触发重新登录
                this.$emit('password-updated');
              } else {
                this.$message.error({
                  message: res.data.message || '修改失败',
                  duration: 3000
                });
              }
            })
            .catch((e) => {
              this.loading = false;
              this.$message.error({
                message: e.message || '网络错误',
                duration: 3000
              });
            });
        } else {
          this.$message.warning('请完善表单信息');
          return false;
        }
      });
    },

    /* 关闭回调 */
    onClose() {
      this.form = {
        oldPassword: "",
        newPassword: "",
        confirmPassword: "",
      };
      this.passwordLevel = 0;
      this.$refs["form"].resetFields();
      this.loading = false;
    },

    /* 取消 */
    cancel() {
      this.updateVisible(false);
    },

    /* 修改visible */
    updateVisible(value) {
      this.$emit("update:visible", value);
    },
  },
};
</script>

<style scoped>
/* 自定义对话框样式 */
:deep(.password-update-dialog) {
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
}

:deep(.password-update-dialog .el-dialog__header) {
  padding: 0;
}

:deep(.password-update-dialog .el-dialog__body) {
  padding: 0;
}

/* 头部样式 */
.dialog-header {
  background: linear-gradient(135deg, #409EFF 0%, #67C23A 100%);
  color: white;
  padding: 24px 30px;
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-icon {
  width: 48px;
  height: 48px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.header-content h3 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
}

.header-content p {
  margin: 4px 0 0;
  font-size: 13px;
  opacity: 0.9;
}

/* 主体内容 */
.dialog-body {
  padding: 24px 30px;
}

/* 密码强度指示器 */
.password-strength {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 12px 16px;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.strength-label {
  font-size: 13px;
  color: #606266;
  white-space: nowrap;
}

.strength-bars {
  flex: 1;
  display: flex;
  gap: 4px;
}

.strength-bar {
  flex: 1;
  height: 4px;
  background: #e4e7ed;
  border-radius: 2px;
  transition: all 0.3s ease;
}

.strength-bar.active {
  background: #67c23a;
}

.strength-bar.active.level-1 {
  background: #f56c6c;
}

.strength-bar.active.level-2 {
  background: #e6a23c;
}

.strength-bar.active.level-3 {
  background: #409eff;
}

.strength-bar.active.level-4 {
  background: #67c23a;
}

.strength-text {
  font-size: 12px;
  font-weight: 600;
  color: #909399;
  min-width: 50px;
}

/* 表单组 */
.form-item-group {
  margin-bottom: 24px;
}

.item-label {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
  color: #303133;
  font-weight: 500;
}

.item-label i {
  color: #409eff;
}

.hint-text {
  font-size: 12px;
  color: #909399;
  font-weight: normal;
}

/* 密码输入框 */
.password-input {
  border-radius: 8px;
}

:deep(.password-input .el-input__inner) {
  border-radius: 8px;
  padding-left: 40px !important;
}

:deep(.password-input .prefix-icon) {
  font-size: 16px;
  color: #c0c4cc;
}

/* 密码提示 */
.password-hints {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 8px;
  margin-top: 8px;
}

.hint-item {
  font-size: 12px;
  color: #c0c4cc;
  display: flex;
  align-items: center;
  gap: 4px;
}

.hint-item.valid {
  color: #67c23a;
}

.hint-item i {
  font-size: 12px;
}

/* 密码匹配提示 */
.password-match {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  margin-top: 6px;
}

.password-match i {
  font-size: 14px;
}

.password-match i.el-icon-success {
  color: #67c23a;
}

.password-match i.el-icon-error {
  color: #f56c6c;
}

/* 底部 */
.dialog-footer {
  border-top: 1px solid #ebeef5;
  padding: 16px 30px;
}

.footer-tips {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #e6a23c;
  font-size: 13px;
  margin-bottom: 16px;
}

.footer-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.cancel-btn {
  width: 100px;
}

.confirm-btn {
  width: 120px;
  background: linear-gradient(135deg, #409EFF 0%, #67C23A 100%);
  border: none;
}

:deep(.confirm-btn:hover) {
  opacity: 0.9;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
}

/* 动画效果 */
@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}

:deep(.password-update-dialog) {
  animation: slideIn 0.3s ease;
}
</style>
