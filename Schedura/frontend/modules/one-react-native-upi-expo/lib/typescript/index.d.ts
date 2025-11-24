interface config {
    upiId: string;
    name: string;
    note: string;
    amount: string;
    targetPackage?: string;
    chooserText?: string;
}
interface success {
    status: 'SUCCESS';
    txnId: string;
    code: string;
    approvalRefNo: string;
}
interface error {
    status: 'FAILED';
    message: string;
}
declare const OneUpi: {
    initiate({ targetPackage, chooserText, ...config }: config, onSuccess: () => success, onFailure: () => error): void;
    getInstalledApps(): () => String[];
};
export default OneUpi;
//# sourceMappingURL=index.d.ts.map