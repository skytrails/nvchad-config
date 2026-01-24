<template>
  <div class="ele-body user-profile-container">
    <div class="profile-content">
      <!-- 余额日志表格 -->
      <el-card shadow="never" class="balance-card">
        <div class="card-header">
          <div class="header-title">
            <i class="el-icon-s-finance header-icon"></i>
            <span>余额变更记录</span>
          </div>
          <div class="header-actions">
            <el-button size="small" type="primary" @click="showBalanceDialog" class="add-balance-btn">
              <i class="el-icon-plus"></i>
              调整余额
            </el-button>
            <el-button size="small" @click="refreshBalanceLog" :loading="balanceLoading">
              <i class="el-icon-refresh"></i>
              刷新
            </el-button>
          </div>
        </div>

        <!-- 余额统计 -->
        <div class="balance-summary">
          <div class="balance-item current-balance">
            <div class="balance-label">
              <i class="el-icon-wallet"></i>
              当前余额
            </div>
            <div class="balance-value">
              ¥ <span class="balance-amount">{{ formatCurrency(currentBalance) }}</span>
            </div>
          </div>
          <div class="balance-item total-recharge">
            <div class="balance-label">
              <i class="el-icon-s-marketing"></i>
              累计充值
            </div>
            <div class="balance-value">
              ¥ <span class="balance-amount">{{ formatCurrency(totalRecharge) }}</span>
            </div>
          </div>
          <div class="balance-item total-consume">
            <div class="balance-label">
              <i class="el-icon-shopping-cart-full"></i>
              累计消费
            </div>
            <div class="balance-value">
              ¥ <span class="balance-amount">{{ formatCurrency(totalConsume) }}</span>
            </div>
          </div>
        </div>

        <!-- 余额表格 -->
        <el-table :data="balanceLogs" v-loading="balanceLoading" style="width: 100%" class="balance-table"
          :header-cell-style="{ background: '#f8f9fa', color: '#495057' }">
          <el-table-column prop="changeTime" label="变更时间" width="180" align="center">
            <template v-slot="{ row }">
              <div class="time-cell">
                <div class="date">{{ formatDate(row.changeTime, 'date') }}</div>
                <div class="time">{{ formatDate(row.changeTime, 'time') }}</div>
              </div>
            </template>
          </el-table-column>

          <el-table-column prop="changeType" label="变更类型" width="120" align="center">
            <template v-slot="{ row }">
              <el-tag :type="getChangeTypeTag(row.changeType)" size="small" effect="light">
                {{ getChangeTypeText(row.changeType) }}
              </el-tag>
            </template>
          </el-table-column>

          <el-table-column prop="changeAmount" label="变更金额" width="120" align="right">
            <template v-slot="{ row }">
              <span :class="{
                'amount-positive': row.changeAmount > 0,
                'amount-negative': row.changeAmount < 0
              }">
                {{ row.changeAmount > 0 ? '+' : '' }}{{ formatCurrency(row.changeAmount) }}
              </span>
            </template>
          </el-table-column>

          <el-table-column prop="balanceAfter" label="变更后余额" width="120" align="right">
            <template v-slot="{ row }">
              <span class="balance-after">
                {{ formatCurrency(row.balanceAfter) }}
              </span>
            </template>
          </el-table-column>

          <el-table-column prop="operator" label="操作人" width="120" align="center">
            <template v-slot="{ row }">
              <div class="operator-cell">
                <circle-avatar text="row.username" size="16" />
                <span class="operator-name">{{ row.operatorName || '-' }}</span>
              </div>
            </template>
          </el-table-column>

          <el-table-column prop="remark" label="备注说明" min-width="200" show-overflow-tooltip>
            <template v-slot="{ row }">
              <div class="remark-cell">
                {{ row.remark || '无备注' }}
              </div>
            </template>
          </el-table-column>

          <el-table-column label="操作" width="80" align="center" fixed="right">
            <template v-slot="{ row }">
              <el-button type="text" size="small" @click="viewDetail(row)" class="detail-btn">
                详情
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页 -->
        <div class="pagination-wrapper">
          <el-pagination :current-page="balanceQuery.page" :page-size="balanceQuery.size" :total="balanceTotal"
            :page-sizes="[10, 20, 50, 100]" layout="total, sizes, prev, pager, next, jumper" background
            @size-change="handleSizeChange" @current-change="handleCurrentChange" />
        </div>
      </el-card>
    </div>

    <!-- 调整余额对话框 -->
    <el-dialog :visible.sync="balanceDialogVisible" title="调整用户余额" width="500px" :destroy-on-close="true">
      <el-form ref="balanceForm" :model="balanceForm" :rules="balanceRules" label-width="100px">
        <el-form-item label="用户姓名">
          <el-input :value="form.realname" disabled />
        </el-form-item>

        <el-form-item label="当前余额">
          <el-input :value="'¥ ' + formatCurrency(currentBalance)" disabled />
        </el-form-item>

        <el-form-item label="调整类型" prop="changeType">
          <el-select v-model="balanceForm.changeType" placeholder="请选择调整类型" class="ele-block">
            <el-option label="充值" :value="1" />
            <el-option label="消费" :value="2" />
            <el-option label="手动调整" :value="3" />
            <el-option label="退款" :value="4" />
            <el-option label="奖励" :value="5" />
          </el-select>
        </el-form-item>

        <el-form-item label="调整金额" prop="changeAmount">
          <el-input-number v-model="balanceForm.changeAmount" :min="0.01" :step="100" placeholder="请输入调整金额"
            class="ele-fluid" controls-position="right">
            <template #prepend>¥</template>
          </el-input-number>
        </el-form-item>

        <el-form-item label="备注说明" prop="remark">
          <el-input v-model="balanceForm.remark" type="textarea" :rows="3" placeholder="请输入调整备注" maxlength="200"
            show-word-limit />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="balanceDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="balanceSubmitLoading" @click="submitBalanceChange">
          确认调整
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import CircleAvatar from '@/components/CircleAvatar.vue';
import { setPageTab } from '@/utils/page-tab-util';

export default {
  name: 'SystemUserInfo',
  components: { CircleAvatar },
  data() {
    return {
      // 省市区数据
      provinces: [
        { label: '北京市', value: '110000' },
        { label: '上海市', value: '310000' },
        { label: '广东省', value: '440000' },
        { label: '浙江省', value: '330000' },
        { label: '江苏省', value: '320000' },
        { label: '四川省', value: '510000' }
      ],
      cities: [],
      districts: [],
      city: [],

      form: {},
      activeTab: 'basic',
      loading: false,
      isUpdate: false,
      roleList: [],
      levelList: [],
      positionList: [],
      deptList: [],
      deptTree: [],
      deptProps: {
        value: 'id',
        label: 'name',
        children: 'children',
        checkStrictly: true
      },

      // 余额相关数据
      balanceDialogVisible: false,
      balanceSubmitLoading: false,
      balanceLoading: false,
      balanceLogs: [],
      balanceTotal: 0,
      currentBalance: 0,
      totalRecharge: 0,
      totalConsume: 0,
      balanceQuery: {
        page: 1,
        size: 10,
        userId: null
      },
      balanceForm: {
        changeType: 1,
        changeAmount: null,
        remark: ''
      }
    };
  },
  computed: {
    // 本地验证规则
    localValidate() {
      return {
        email: /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/,
        phone: /^1[3-9]\d{9}$/
      };
    },

    // 验证规则
    rules() {
      return {
        realname: [
          { required: true, message: '请输入用户姓名', trigger: 'blur' }
        ],
        nickname: [
          { required: true, message: '请输入用户名', trigger: 'blur' }
        ],
        gender: [
          { required: true, message: '请选择性别', trigger: 'blur' }
        ],
        birthday: [
          { required: true, message: '请选择出生日期', trigger: 'blur' }
        ],
        email: [
          { pattern: this.localValidate.email, message: '邮箱格式不正确', trigger: 'blur' }
        ],
        mobile: [
          { pattern: this.localValidate.phone, message: '手机号格式不正确', trigger: 'blur' }
        ]
      };
    },

    workRules() {
      return {
        levelId: [
          { required: true, message: '请选择职级', trigger: 'blur' }
        ],
        positionId: [
          { required: true, message: '请选择岗位', trigger: 'blur' }
        ],
        deptId: [
          { required: true, message: '请选择部门', trigger: 'blur' }
        ],
        status: [
          { required: true, message: '请选择状态', trigger: 'blur' }
        ],
        sort: [
          { required: true, message: '请输入排序号', trigger: 'blur' }
        ],
        roleIds: [
          { required: true, message: '请选择角色', trigger: 'blur' }
        ]
      };
    },

    balanceRules() {
      return {
        changeType: [
          { required: true, message: '请选择调整类型', trigger: 'blur' }
        ],
        changeAmount: [
          { required: true, message: '请输入调整金额', trigger: 'blur' },
          {
            validator: (rule, value, callback) => {
              if (value <= 0) {
                callback(new Error('调整金额必须大于0'));
              } else {
                callback();
              }
            },
            trigger: 'blur'
          }
        ]
      };
    },

    levelName() {
      if (!this.form.levelId) return '';
      const level = this.levelList.find(item => item.id === this.form.levelId);
      return level ? level.name : '';
    },

    positionName() {
      if (!this.form.positionId) return '';
      const position = this.positionList.find(item => item.id === this.form.positionId);
      return position ? position.name : '';
    }
  },
  mounted() {
    const userId = this.$route.query.id;
    this.query(userId);
    this.queryRoles();
    this.getLevelList();
    this.getPositionList();
    this.getDeptList();
  },
  methods: {
    /* 查询用户信息 */
    query(id) {
      if (!id) return;

      this.loading = true;
      this.balanceQuery.userId = id;

      Promise.all([
        this.$http.get('/user/info/' + id).then(userRes => {
          if (userRes.data.code === 0) {
            const userData = userRes.data.data;
            this.form = Object.assign({}, userData, {
              roleIds: userData.roles ? userData.roles.map(d => d.id) : []
            });

            // 处理城市数据
            if (userData.city && Array.isArray(userData.city)) {
              this.city = [...userData.city];
            } else {
              this.city = [];
            }

            this.currentBalance = userData.balance || 0;
            this.isUpdate = true;

            setPageTab({
              fullPath: this.$route.fullPath,
              title: this.form.realname + '的详情'
            });
          } else {
            this.$message.error(userRes.data.msg);
          }
        }),
        this.getBalanceLogs()
      ]).then(() => {
        this.loading = false;
      }).catch((e) => {
        this.loading = false;
        this.$message.error(e.message);
      });
    },

    /* 省市区选择相关方法 */
    handleProvinceChange(province) {
      if (!province) {
        this.cities = [];
        this.districts = [];
        this.city[1] = null;
        this.city[2] = null;
        return;
      }

      // 模拟根据省份获取城市数据
      const cityData = {
        '110000': [
          { label: '北京市', value: '110100' }
        ],
        '310000': [
          { label: '上海市', value: '310100' }
        ],
        '440000': [
          { label: '广州市', value: '440100' },
          { label: '深圳市', value: '440300' },
          { label: '珠海市', value: '440400' }
        ]
      };

      this.cities = cityData[province] || [];
      this.city[1] = null;
      this.city[2] = null;
      this.districts = [];
    },

    handleCityChange(city) {
      if (!city) {
        this.districts = [];
        this.city[2] = null;
        return;
      }

      // 模拟根据城市获取区县数据
      const districtData = {
        '440100': [
          { label: '天河区', value: '440106' },
          { label: '越秀区', value: '440104' },
          { label: '海珠区', value: '440105' }
        ],
        '440300': [
          { label: '福田区', value: '440304' },
          { label: '南山区', value: '440305' },
          { label: '罗湖区', value: '440303' }
        ]
      };

      this.districts = districtData[city] || [];
      this.city[2] = null;
    },

    /* 获取余额变更记录 */
    getBalanceLogs() {
      if (!this.balanceQuery.userId) return Promise.resolve();

      this.balanceLoading = true;
      // 模拟数据
      return new Promise(resolve => {
        setTimeout(() => {
          this.balanceLogs = [
            {
              id: 1,
              changeTime: new Date('2024-01-15 10:30:00'),
              changeType: 1,
              changeAmount: 1000,
              balanceAfter: 1000,
              operatorName: '管理员',
              operatorAvatar: '',
              remark: '用户充值'
            },
            {
              id: 2,
              changeTime: new Date('2024-01-16 14:20:00'),
              changeType: 2,
              changeAmount: -200,
              balanceAfter: 800,
              operatorName: '系统',
              operatorAvatar: '',
              remark: '购买商品'
            },
            {
              id: 3,
              changeTime: new Date('2024-01-18 09:15:00'),
              changeType: 5,
              changeAmount: 100,
              balanceAfter: 900,
              operatorName: '管理员',
              operatorAvatar: '',
              remark: '活动奖励'
            },
            {
              id: 2,
              changeTime: new Date('2024-01-16 14:20:00'),
              changeType: 2,
              changeAmount: -200,
              balanceAfter: 800,
              operatorName: '系统',
              operatorAvatar: '',
              remark: '购买商品'
            },
            {
              id: 2,
              changeTime: new Date('2024-01-16 14:20:00'),
              changeType: 2,
              changeAmount: -200,
              balanceAfter: 800,
              operatorName: '系统',
              operatorAvatar: '',
              remark: '购买商品'
            },
            {
              id: 2,
              changeTime: new Date('2024-01-16 14:20:00'),
              changeType: 2,
              changeAmount: -200,
              balanceAfter: 800,
              operatorName: '系统',
              operatorAvatar: '',
              remark: '购买商品'
            },
            {
              id: 2,
              changeTime: new Date('2024-01-16 14:20:00'),
              changeType: 2,
              changeAmount: -200,
              balanceAfter: 800,
              operatorName: '系统',
              operatorAvatar: '',
              remark: '购买商品'
            },
            {
              id: 2,
              changeTime: new Date('2024-01-16 14:20:00'),
              changeType: 2,
              changeAmount: -200,
              balanceAfter: 800,
              operatorName: '系统',
              operatorAvatar: '',
              remark: '购买商品'
            },
            {
              id: 2,
              changeTime: new Date('2024-01-16 14:20:00'),
              changeType: 2,
              changeAmount: -200,
              balanceAfter: 800,
              operatorName: '系统',
              operatorAvatar: '',
              remark: '购买商品'
            },
            {
              id: 2,
              changeTime: new Date('2024-01-16 14:20:00'),
              changeType: 2,
              changeAmount: -200,
              balanceAfter: 800,
              operatorName: '系统',
              operatorAvatar: '',
              remark: '购买商品'
            },
          ];

          this.balanceTotal = 50;
          this.calculateBalanceStats();
          this.balanceLoading = false;
          resolve();
        }, 500);
      });
    },

    /* 计算余额统计 */
    calculateBalanceStats() {
      this.totalRecharge = this.balanceLogs
        .filter(log => log.changeAmount > 0)
        .reduce((sum, log) => sum + log.changeAmount, 0);

      this.totalConsume = this.balanceLogs
        .filter(log => log.changeAmount < 0)
        .reduce((sum, log) => sum + Math.abs(log.changeAmount), 0);
    },

    /* 刷新余额记录 */
    refreshBalanceLog() {
      this.getBalanceLogs();
    },

    /* 显示余额调整对话框 */
    showBalanceDialog() {
      this.balanceForm = {
        changeType: 1,
        changeAmount: null,
        remark: ''
      };
      this.balanceDialogVisible = true;
    },

    /* 提交余额调整 */
    submitBalanceChange() {
      this.$refs.balanceForm.validate((valid) => {
        if (valid) {
          this.balanceSubmitLoading = true;
          // 模拟API调用
          setTimeout(() => {
            this.balanceSubmitLoading = false;
            this.$message.success('余额调整成功');
            this.balanceDialogVisible = false;
            this.getBalanceLogs();

            // 更新当前余额
            if (this.balanceForm.changeAmount) {
              this.currentBalance += this.balanceForm.changeAmount;
              this.form.balance = this.currentBalance;
            }
          }, 1000);
        }
      });
    },

    /* 头像上传 */
    beforeAvatarUpload(file) {
      const isImage = file.type.startsWith('image/');
      const isLt2M = file.size / 1024 / 1024 < 2;

      if (!isImage) {
        this.$message.error('只能上传图片文件!');
        return false;
      }
      if (!isLt2M) {
        this.$message.error('图片大小不能超过2MB!');
        return false;
      }
      return true;
    },

    handleAvatarUpload(file) {
      // 这里应该是实际上传到服务器的逻辑
      const reader = new FileReader();
      reader.onload = (e) => {
        this.form.avatar = e.target.result;
      };
      reader.readAsDataURL(file.file);
    },

    /* 查看详情 */
    viewDetail(row) {
      this.$message.info('查看详情：' + row.id);
    },

    /* 分页处理 */
    handleSizeChange(val) {
      this.balanceQuery.size = val;
      this.getBalanceLogs();
    },

    handleCurrentChange(val) {
      this.balanceQuery.page = val;
      this.getBalanceLogs();
    },

    /* 获取变更类型文本 */
    getChangeTypeText(type) {
      const types = {
        1: '充值',
        2: '消费',
        3: '调整',
        4: '退款',
        5: '奖励'
      };
      return types[type] || '未知';
    },

    /* 获取变更类型标签样式 */
    getChangeTypeTag(type) {
      const tags = {
        1: 'success',  // 充值
        2: 'danger',   // 消费
        3: 'info',     // 调整
        4: 'warning',  // 退款
        5: 'primary'   // 奖励
      };
      return tags[type] || 'info';
    },

    /* 格式化金额 */
    formatCurrency(amount) {
      if (amount === null || amount === undefined) return '0.00';
      return Number(amount).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    },

    /* 格式化日期 */
    formatDate(date, type = 'full') {
      if (!date) return '-';

      const d = new Date(date);

      if (type === 'date') {
        const year = d.getFullYear();
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
      } else if (type === 'time') {
        const hour = String(d.getHours()).padStart(2, '0');
        const minute = String(d.getMinutes()).padStart(2, '0');
        const second = String(d.getSeconds()).padStart(2, '0');
        return `${hour}:${minute}:${second}`;
      }

      const year = d.getFullYear();
      const month = String(d.getMonth() + 1).padStart(2, '0');
      const day = String(d.getDate()).padStart(2, '0');
      const hour = String(d.getHours()).padStart(2, '0');
      const minute = String(d.getMinutes()).padStart(2, '0');
      const second = String(d.getSeconds()).padStart(2, '0');

      return `${year}-${month}-${day} ${hour}:${minute}:${second}`;
    },

    /* 验证邮箱格式 */
    isValidEmail(email) {
      return this.localValidate.email.test(email);
    },

    /* 部门树形数据转换 */
    buildDeptTree(depts, pid = 0) {
      return depts
        .filter(item => item.pid === pid)
        .map(item => ({
          id: item.id,
          name: item.name,
          children: this.buildDeptTree(depts, item.id)
        }));
    },

    /* 获取角色名称 */
    getRoleName(roleId) {
      const role = this.roleList.find(r => r.id === roleId);
      return role ? role.name : '未知角色';
    },

    /* 移除角色 */
    removeRole(roleId) {
      this.form.roleIds = this.form.roleIds.filter(id => id !== roleId);
    },

    /* 重置表单 */
    resetForm() {
      if (this.$refs.basicForm) {
        this.$refs.basicForm.resetFields();
      }
      if (this.$refs.workForm) {
        this.$refs.workForm.resetFields();
      }
    },

    /* 保存编辑 */
    save() {
      const validations = [];

      if (this.$refs.basicForm) {
        validations.push(new Promise(resolve => {
          this.$refs.basicForm.validate(valid => {
            resolve(valid);
          });
        }));
      }

      if (this.activeTab === 'work' && this.$refs.workForm) {
        validations.push(new Promise(resolve => {
          this.$refs.workForm.validate(valid => {
            resolve(valid);
          });
        }));
      }

      Promise.all(validations).then(results => {
        const allValid = results.every(result => result === true);

        if (allValid) {
          this.loading = true;

          // 处理表单数据
          // const formData = {
          //   ...this.form,
          //   city: this.city
          // };

          // 模拟API调用
          setTimeout(() => {
            this.loading = false;
            this.$message.success('保存�����功');
          }, 1000);
        }
      });
    },

    /* 查询角色列表 */
    queryRoles() {
      // 模拟数据
      this.roleList = [
        { id: 1, name: '管理员' },
        { id: 2, name: '普通用户' },
        { id: 3, name: 'VIP用户' },
        { id: 4, name: '测试用户' }
      ];
    },

    /* 获取职级列表 */
    getLevelList() {
      // 模拟数据
      this.levelList = [
        { id: 1, name: '初级' },
        { id: 2, name: '中级' },
        { id: 3, name: '高级' },
        { id: 4, name: '专家' }
      ];
    },

    /* 获取岗位列表 */
    getPositionList() {
      // 模拟数据
      this.positionList = [
        { id: 1, name: '前端开发' },
        { id: 2, name: '后端开发' },
        { id: 3, name: '产品经理' },
        { id: 4, name: 'UI设计师' }
      ];
    },

    /* 获取部门列表 */
    getDeptList() {
      // 模拟数据
      const depts = [
        { id: 1, name: '技术部', pid: 0 },
        { id: 2, name: '市场部', pid: 0 },
        { id: 3, name: '人事部', pid: 0 },
        { id: 4, name: '前端组', pid: 1 },
        { id: 5, name: '后端组', pid: 1 },
        { id: 6, name: '测试组', pid: 1 }
      ];

      this.deptList = depts;
      this.deptTree = this.buildDeptTree(depts);
    }
  },

  watch: {
    $route() {
      const userId = this.$route.query.id;
      this.query(userId);
    }
  }
};
</script>

<style scoped>
/* 样式保持不变 */
.user-profile-container {
  padding: 20px;
}

.page-header {
  margin-bottom: 24px;
}

.page-title {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 8px 0;
}

.page-subtitle {
  font-size: 14px;
  color: #909399;
  margin: 0;
}

.profile-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* 余额卡片样式 */
.balance-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 0 16px 0;
  border-bottom: 1px solid #f0f0f0;
}

.header-title {
  display: flex;
  align-items: center;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.header-icon {
  margin-right: 8px;
  color: #409eff;
  font-size: 18px;
}

.header-actions {
  display: flex;
  gap: 8px;
}

.add-balance-btn {
  background: linear-gradient(135deg, #67c23a 0%, #5daf34 100%);
  border: none;
}

/* 余额统计 */
.balance-summary {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin: 20px 0;
}

.balance-item {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 16px;
  border-left: 4px solid #409eff;
}

.balance-item.total-recharge {
  border-left-color: #67c23a;
}

.balance-item.total-consume {
  border-left-color: #f56c6c;
}

.balance-label {
  display: flex;
  align-items: center;
  font-size: 14px;
  color: #606266;
  margin-bottom: 8px;
}

.balance-label i {
  margin-right: 6px;
  font-size: 16px;
}

.balance-value {
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}

.balance-amount {
  font-size: 24px;
}

/* 余额表格 */
.balance-table {
  margin-top: 16px;
}

.time-cell {
  display: flex;
  flex-direction: column;
}

.date {
  font-weight: 500;
  color: #303133;
}

.time {
  font-size: 12px;
  color: #909399;
}

.amount-positive {
  color: #67c23a;
  font-weight: 500;
}

.amount-negative {
  color: #f56c6c;
  font-weight: 500;
}

.balance-after {
  font-weight: 600;
  color: #409eff;
}

.operator-cell {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.operator-avatar {
  flex-shrink: 0;
}

.operator-name {
  font-size: 14px;
}

.remark-cell {
  color: #606266;
  line-height: 1.5;
}

.detail-btn {
  color: #409eff;
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

/* 用户信息卡片样式 */
.profile-card {
  margin-top: 20px;
}

.user-header {
  display: flex;
  gap: 24px;
  padding-bottom: 24px;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 24px;
}

.avatar-section {
  flex-shrink: 0;
}

.avatar-wrapper {
  text-align: center;
}

.avatar-preview {
  margin-bottom: 12px;
}

.avatar-placeholder {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 32px;
  font-weight: bold;
}

.avatar-placeholder i {
  font-size: 48px;
  margin-bottom: 4px;
}

.upload-trigger {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: #f5f7fa;
  border-radius: 4px;
  color: #606266;
  cursor: pointer;
  transition: all 0.3s;
}

.upload-trigger:hover {
  background: #e4e7ed;
}

.user-summary {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.user-name h3 {
  margin: 0 0 12px 0;
  font-size: 24px;
  color: #303133;
}

.user-tags {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.user-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

.stat-item {
  display: flex;
  flex-direction: column;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
}

.balance-stat {
  color: #67c23a;
  font-weight: 600;
}

/* 选项卡样式 */
.profile-tabs {
  margin-top: 20px;
}

.form-section {
  margin-bottom: 32px;
}

.section-title {
  display: flex;
  align-items: center;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 16px 0;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.section-title i {
  margin-right: 8px;
  color: #409eff;
}

.compact-form :deep(.el-form-item) {
  margin-bottom: 18px;
}

.phone-prefix {
  padding: 0 12px;
  color: #606266;
}

.email-valid-icon {
  color: #67c23a;
  font-weight: bold;
}

.form-tips {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

/* 状态单选样式 */
.status-form-item :deep(.el-radio-group) {
  display: flex;
  gap: 24px;
}

.status-radio {
  width: 160px;
  height: 80px;
  border-radius: 8px;
  border: 1px solid #dcdfe6;
  padding: 12px;
}

.status-radio :deep(.el-radio__label) {
  padding-left: 0;
}

.status-content {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.status-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: #909399;
}

.status-radio.status-active .status-dot {
  background-color: #67c23a;
  box-shadow: 0 0 8px rgba(103, 194, 58, 0.3);
}

.status-radio.status-disabled .status-dot {
  background-color: #f56c6c;
  box-shadow: 0 0 8px rgba(245, 108, 108, 0.3);
}

.status-desc {
  font-size: 12px;
  color: #909399;
}

/* 角色选择样式 */
.role-selection-info {
  margin-top: 8px;
}

.selected-count {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #409eff;
  font-weight: 500;
}

.role-tips {
  font-size: 12px;
  color: #909399;
  margin-top: 2px;
}

.selected-roles {
  margin-top: 16px;
}

.roles-title {
  font-size: 14px;
  font-weight: 500;
  color: #606266;
  margin-bottom: 8px;
}

.roles-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.role-tag {
  transition: all 0.3s;
}

.role-tag:hover {
  transform: translateY(-2px);
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #f0f0f0;
}

.save-btn {
  min-width: 120px;
  background: linear-gradient(135deg, #409eff 0%, #337ecc 100%);
  border: none;
  box-shadow: 0 2px 6px rgba(64, 158, 255, 0.2);
}

.save-btn:hover {
  background: linear-gradient(135deg, #66b1ff 0%, #409eff 100%);
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.3);
}

.reset-btn {
  min-width: 120px;
}

/* 响应式调整 */
@media (max-width: 992px) {
  .user-header {
    flex-direction: column;
    text-align: center;
  }

  .user-stats {
    grid-template-columns: repeat(2, 1fr);
  }

  .balance-summary {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .user-stats {
    grid-template-columns: 1fr;
  }

  .status-form-item :deep(.el-radio-group) {
    flex-direction: column;
    gap: 12px;
  }

  .status-radio {
    width: 100%;
  }
}
</style>
